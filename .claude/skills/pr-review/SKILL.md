---
name: pr-review
description: Opens a GitHub PR from the current repo in Hunk, in a new tmux window on the user's real session (never the Claude popup), then annotates the diff inline with orientation notes and review findings. Accepts a PR number, branch name, title fragment, or URL. Use when the user wants to review a pull request interactively.
---

# PR Review

Given a PR reference, put that PR's diff on screen in Hunk and annotate it so the
user can read the review inline, next to the code it describes.

This skill builds on `hunk-review`, which must be installed alongside it — the
launch script reuses its `resolve_host_session.sh`. Read that skill for the full
`hunk session *` command surface; this one covers only the PR-specific flow.

**Never run `hunk diff` / `hunk show` in your own Bash tool.** It is a blocking
TUI and will hang. The script below launches it in the user's terminal instead;
you drive it afterwards through `hunk session *`.

## Step 1 — open the PR

```bash
~/.claude/skills/pr-review/scripts/open_pr_review.sh <pr>
```

`<pr>` may be a number (`412`), a branch (`feat/token-refresh`), a title
fragment (`"token refresh"`), or a PR URL. Resolution tries, in order: a direct
lookup (number / URL / local branch), a `--head` branch match (which also
catches PRs opened from a fork), then an `in:title` search. An exact title match
wins over fuzzy neighbours; anything still ambiguous exits 2 with the candidate
list on stderr, so pass the number instead.

The script resolves the PR, fetches `refs/pull/<n>/head` and the base branch
into a private `refs/hunk-pr/*` namespace, and opens `hunk diff <base>...<head>`
in a new tmux window on the real session underneath the Claude popup. If a Hunk
session is already live for this repo it reloads that session instead of opening
a second window. Nothing about the user's working tree, branch, or checkout is
touched.

It prints a `key: value` block — keep `pr_number`, `range`, `repo_root`, and
`changed_files`; you need them below.

## Step 2 — understand the change before annotating

Do not annotate straight off the diff. Gather context first:

```bash
gh pr view <n> --json title,body,author,commits,labels
hunk session review --repo . --json          # file / hunk structure
```

`session review --json` gives you the file and hunk layout without pulling raw
patch text into context. Add `--include-patch` only for files you genuinely need
to read as a diff.

Then read the *real files* around the changed lines — `git show`, or Read on the
working-tree copy. A diff hides whether a change is correct; the surrounding
function usually decides it. For anything non-trivial, also check the callers of
what changed.

## Step 3 — annotate

Two kinds of note, distinguished by a marker at the start of the summary:

- `⚠` — a **finding**: a bug, a race, an unhandled case, a risky migration,
  a missing test for a branch that clearly needs one. Something the user should
  act on.
- `ℹ` — **orientation**: what this part does, why it exists, where to start
  reading, how it connects to the rest. Something that saves the user time.

Put the claim in `summary` and the reasoning in `rationale`. Keep the summary to
one line — it is what shows inline.

Batch them in a single `comment apply` rather than many `comment add` calls:

```bash
jq -n '{comments: [
  {filePath: "src/auth.ts", newLine: 88,
   summary: "ℹ Entry point — everything below flows from here",
   rationale: "The refresh path moved out of api.ts; this is where the new flow starts."},
  {filePath: "src/auth.ts", newLine: 42,
   summary: "⚠ Token refresh races on concurrent requests",
   rationale: "Two callers hitting an expired token both enter refresh; the second overwrites the first's result. Needs a single-flight guard."}
]}' | hunk session comment apply --repo . --stdin
```

Build the payload with `jq -n` (as above) or a heredoc — never by hand-splicing
strings into JSON, since summaries and rationales contain quotes and backticks.
The batch is validated in full before anything mutates, so a malformed item
fails cleanly.

Each item needs `filePath`, `summary`, and exactly one target: `newLine`,
`oldLine`, `hunk`, or `hunkNumber`. Use `newLine` for added or changed code and
`oldLine` when the point is about something the PR removed.

Then park the user's view on the note they should read first:

```bash
hunk session navigate --repo . --file src/auth.ts --new-line 88
```

Guidelines:

- Order by what tells the clearest story, not by file path. Lead with the
  entry point, then follow the flow.
- One `ℹ` per meaningful area is usually enough. Do not narrate every hunk —
  restating the diff in prose is noise.
- Every `⚠` must be specific enough to act on. "Consider error handling" is
  not a finding; "throws on empty `items`, and `render()` calls it unguarded"
  is.
- If the PR is genuinely clean, say so in the summary and leave only the `ℹ`
  notes. Do not invent findings to look thorough.
- Scale to the diff: a 3-file PR might warrant 4 notes, a 40-file one maybe 15.
  `changed_files` from step 1 is your budget hint.

## Step 4 — summarize

Report back in chat, briefly: what the PR does, how many notes you left and
where, and the findings ranked by severity. Tell the user the window is named
`pr-<n>` on their session. If they ask to be walked through the notes rather
than reading them alone, step their view with:

```bash
hunk session navigate --repo . --next-comment
```

If you found nothing actionable, say that plainly rather than padding.

## Errors

- **"not inside tmux"** — the script needs `$TMUX` to place the window. Ask the
  user to start tmux, or launch `hunk diff <range>` themselves.
- **"resolve_host_session.sh not found"** — the `hunk-review` skill is not
  installed. Both are symlinked by `install_folder.sh` in the dotfiles repo.
- **"N open PRs match"** — the lookup was ambiguous; the candidates are listed
  on stderr. Ask the user which, or pass the number.
- **"GitHub API error while ..."** — auth, network, or a GitHub 5xx (the script
  already retried once). This is *not* "no such PR"; report the API failure and
  retry rather than telling the user their PR does not exist.
- **"could not fetch refs/pull/<n>/head"** — the remote may not be the PR's
  repo, or the PR number is from a different project. Check `git remote -v`.
- **"no session registered after 15s"** — the window opened but the daemon never
  saw it. Localhost may be blocked by the agent sandbox; retry with escalation.
- **"No visible diff file matches ..."** — you are commenting on a file outside
  the loaded range. Re-check `hunk session review --repo . --json`.
