#!/usr/bin/env bash
# Resolve a PR, fetch its refs, and open it in Hunk in a new tmux window on the
# user's real (non-popup) session.
#
# Usage: open_pr_review.sh <number | branch | title fragment | url>
#
# Prints a block of "key: value" lines on stdout describing what was opened.
# Everything diagnostic goes to stderr.
set -uo pipefail

die() {
    printf 'pr-review: %s\n' "$1" >&2
    exit "${2:-1}"
}

arg="${1:-}"
[ -n "$arg" ] || die "no PR given; pass a number, branch name, title fragment, or URL"

for tool in gh hunk tmux git jq; do
    command -v "$tool" >/dev/null 2>&1 || die "'$tool' not found on PATH"
done

[ -n "${TMUX:-}" ] || die "not inside tmux; start tmux (or launch Hunk manually) first"

repo_root="$(git rev-parse --show-toplevel 2>/dev/null)" ||
    die "not inside a git repository"

gh auth status >/dev/null 2>&1 ||
    die "gh is not authenticated; run: gh auth login"

# --- resolve the PR ------------------------------------------------------
# `gh pr view` already accepts a number, a URL, and a branch name, so try it
# directly before falling back to a title search.
FIELDS='number,title,url,baseRefName,headRefName,isCrossRepository,state,changedFiles,additions,deletions'

ambiguous() {
    printf "pr-review: %s open PRs match '%s':\n" "$1" "$arg" >&2
    jq -r '.[] | "  #\(.number)  \(.title)  [\(.headRefName)]"' <<<"$2" >&2
    die "narrow the search, or pass the PR number" 2
}

# `gh pr list` returns [] when nothing matches, so a non-zero exit is a real
# failure (auth, network, a GitHub 5xx) and must not be reported as "no match".
# One retry, since the API 503s intermittently.
pr_list() {
    local desc="$1" out rc errfile attempt
    shift
    errfile="$(mktemp)"
    for attempt in 1 2; do
        out="$(gh pr list "$@" --state open --json "$FIELDS" --limit 20 2>"$errfile")"
        rc=$?
        [ $rc -eq 0 ] && break
    done
    if [ $rc -ne 0 ]; then
        local msg
        msg="$(head -1 "$errfile")"
        rm -f "$errfile"
        die "GitHub API error while ${desc}: ${msg:-gh exited ${rc}}" 4
    fi
    rm -f "$errfile"
    printf '%s' "${out:-[]}"
}

# 1. number, URL, or a branch in this repo. A failure here is normal (it just
#    means the argument is not one of those), so it stays quiet.
pr_json="$(gh pr view "$arg" --json "$FIELDS" 2>/dev/null)"

# 2. branch name. `gh pr view <branch>` only knows branches in this repo, so
#    PRs opened from a fork need the explicit --head filter.
if [ -z "$pr_json" ]; then
    by_head="$(pr_list "looking up branch '${arg}'" --head "$arg")" || exit $?
    n="$(jq 'length' <<<"$by_head")"
    if [ "$n" = "1" ]; then
        pr_json="$(jq '.[0]' <<<"$by_head")"
    elif [ "$n" != "0" ]; then
        ambiguous "$n" "$by_head"
    fi
fi

# 3. title fragment. `in:title` keeps the search off PR bodies; GitHub still
#    matches loosely within the title, so prefer an exact title when present.
if [ -z "$pr_json" ]; then
    matches="$(pr_list "searching titles for '${arg}'" --search "$arg in:title")" || exit $?

    exact="$(jq --arg q "$arg" \
        '[.[] | select((.title | ascii_downcase) == ($q | ascii_downcase))]' <<<"$matches")"
    n="$(jq 'length' <<<"$matches")"

    if [ "$(jq 'length' <<<"$exact")" = "1" ]; then
        pr_json="$(jq '.[0]' <<<"$exact")"
    else
        case "$n" in
            0) die "no open PR matches '$arg'" ;;
            1) pr_json="$(jq '.[0]' <<<"$matches")" ;;
            *) ambiguous "$n" "$matches" ;;
        esac
    fi
fi

num="$(jq -r '.number' <<<"$pr_json")"
title="$(jq -r '.title' <<<"$pr_json")"
url="$(jq -r '.url' <<<"$pr_json")"
base_branch="$(jq -r '.baseRefName' <<<"$pr_json")"
head_branch="$(jq -r '.headRefName' <<<"$pr_json")"
state="$(jq -r '.state' <<<"$pr_json")"
changed="$(jq -r '.changedFiles' <<<"$pr_json")"
adds="$(jq -r '.additions' <<<"$pr_json")"
dels="$(jq -r '.deletions' <<<"$pr_json")"
cross="$(jq -r '.isCrossRepository' <<<"$pr_json")"

# --- fetch the refs ------------------------------------------------------
# refs/pull/<n>/head works for fork PRs too, so it beats guessing at a remote
# branch. Both refs land in a private refs/hunk-pr/* namespace rather than
# creating local branches.
if git remote | grep -qx 'origin'; then
    remote='origin'
else
    remote="$(git remote | head -1)"
fi
[ -n "$remote" ] || die "no git remote configured"

head_ref="refs/hunk-pr/${num}/head"
base_ref="refs/hunk-pr/${num}/base"

git fetch --quiet "$remote" "+refs/pull/${num}/head:${head_ref}" 2>/dev/null ||
    die "could not fetch refs/pull/${num}/head from '${remote}'"
git fetch --quiet "$remote" "+refs/heads/${base_branch}:${base_ref}" 2>/dev/null ||
    die "could not fetch base branch '${base_branch}' from '${remote}'"

# Three-dot: diff the head against the merge base, so unrelated commits landed
# on the base branch since the PR opened do not show up as part of the review.
range="${base_ref}...${head_ref}"
merge_base="$(git merge-base "$base_ref" "$head_ref" 2>/dev/null || echo '')"

# --- put it on screen ----------------------------------------------------
if hunk session get --repo "$repo_root" >/dev/null 2>&1; then
    # A Hunk session is already live for this repo - swap its contents rather
    # than piling up windows.
    hunk session reload --repo "$repo_root" -- diff "$range" >/dev/null ||
        die "failed to reload the live Hunk session"
    action='reloaded existing session'

    # Keep the window label honest after a swap: rename the pr-* window sitting
    # in this repo, so it does not still advertise the previously loaded PR.
    target_session="$(tmux display-message -p '#S')"
    while read -r win name path; do
        if [ "$path" = "$repo_root" ] && [[ "$name" == pr-* ]]; then
            tmux rename-window -t "$win" "pr-${num}" 2>/dev/null
            target_session="${win%%:*}"
            break
        fi
    done < <(tmux list-windows -a -F '#{session_name}:#{window_index} #{window_name} #{pane_current_path}' 2>/dev/null)
else
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    resolve=''
    for candidate in \
        "${script_dir}/../../hunk-review/scripts/resolve_host_session.sh" \
        "${HOME}/.claude/skills/hunk-review/scripts/resolve_host_session.sh" \
        "${HOME}/dotfiles/.claude/skills/hunk-review/scripts/resolve_host_session.sh"; do
        if [ -x "$candidate" ]; then
            resolve="$candidate"
            break
        fi
    done
    [ -n "$resolve" ] ||
        die "resolve_host_session.sh not found; the hunk-review skill must be installed alongside this one"

    target_session="$("$resolve")" || die "could not resolve a target tmux session"

    tmux new-window -t "$target_session" -n "pr-${num}" -c "$repo_root" \
        "hunk diff '${range}'" ||
        die "failed to open a tmux window on session '${target_session}'"
    action='opened new window'

    # The daemon registers the session a moment after the TUI starts.
    registered='no'
    for _ in $(seq 1 60); do
        if hunk session get --repo "$repo_root" >/dev/null 2>&1; then
            registered='yes'
            break
        fi
        sleep 0.25
    done
    [ "$registered" = 'yes' ] ||
        die "Hunk window opened on '${target_session}' but no session registered after 15s" 3
fi

cat <<EOF
action: ${action}
pr_number: ${num}
pr_state: ${state}
pr_url: ${url}
base_branch: ${base_branch}
head_branch: ${head_branch}
cross_repository: ${cross}
range: ${range}
merge_base: ${merge_base}
changed_files: ${changed}
additions: ${adds}
deletions: ${dels}
repo_root: ${repo_root}
tmux_session: ${target_session}
pr_title: ${title}
EOF
