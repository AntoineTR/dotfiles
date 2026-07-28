---
name: hunk-review
description: Interacts with live Hunk diff review sessions via CLI. Launches Hunk itself (in a new tmux window on the real session, never the Claude popup) when none is running. Inspects review focus, navigates files and hunks, reloads session contents, and adds inline review comments. Use when the user wants to review diffs interactively, with or without a Hunk session already running.
---

# Hunk Review

Hunk is an interactive terminal diff viewer. The TUI is for the user — do NOT run
`hunk diff`, `hunk show`, or other interactive commands directly in your own Bash tool
call; it's a blocking TUI and would just hang. Use `hunk session *` CLI commands to
inspect and control live sessions through the local daemon. Launching Hunk itself for
the user (see below) is fine — that puts the interactive TUI in a new tmux window on
the user's own terminal, not in your own Bash call.

## Launching Hunk (if no session exists)

If `hunk session list` shows nothing for the repo you need to review, launch it
yourself rather than asking the user to run it manually — but never inside the Claude
popup modal (see below), always in a new tmux window on the real session underneath.

Requires `tmux` (check `$TMUX` is set — if not, ask the user to launch Hunk manually).

1. Resolve the real target session:
   ```
   session="$(~/.claude/skills/hunk-review/scripts/resolve_host_session.sh)"
   ```
2. Open Hunk in a new window there:
   ```
   repo_root="$(git rev-parse --show-toplevel)"
   tmux new-window -t "$session" -n "hunk-review" "cd '$repo_root' && hunk diff <target>"
   ```
   Swap `hunk diff <target>` for whatever's being reviewed (`hunk diff`, `hunk diff
   main...feature`, `hunk show HEAD~1`, `hunk diff --staged`, etc).
3. Give the daemon a moment to register the new session, then continue with the
   `hunk session *` workflow below.

### Why not just launch it in place

Claude Code is normally launched via `tmux-claude-session-manager` (`ctrl+a y` to
launch/attach, `ctrl+a u` for its picker), which runs Claude inside its own background
tmux session (named `claude-<hash>` by default) shown to the user as a floating
`tmux display-popup` *over* their real working session. Plain
`tmux display-message -p '#S'` from in here returns that ephemeral popup session — a
window opened there is invisible to the user once the popup closes, and disappears
from view even while it's open. `resolve_host_session.sh` detects this (walking the
plugin's own `@claude_origin` bookkeeping, falling back to the outer attached client)
and returns the session underneath instead. Outside the popup it's a no-op and just
returns the current session.

If it prints a warning to stderr (no outer session found), tell the user so they can
check — don't silently open the window against the popup session anyway.

## Workflow

```text
1. hunk session list                                    # find live sessions
2. hunk session get --repo .                            # inspect path / repo / source
3. hunk session review --repo . --json                  # inspect file/hunk structure first
4. hunk session review --repo . --include-patch --json  # opt into raw diff text only when needed
5. hunk session context --repo .                        # check current focus when needed
6. hunk session navigate ...                             # move to the right place
7. hunk session reload -- <command>                     # swap contents if needed
8. hunk session comment add ...                         # leave one review note
9. hunk session comment apply ...                       # apply many agent notes in one stdin batch
```

## Session selection

Most session commands accept:

- `--repo <path>` -- match the live session by its current loaded repo root (most common)
- `<session-id>` -- match by exact ID (use when multiple sessions share a repo)
- If only one session exists, it auto-resolves

`reload` also supports:

- `--session-path <path>` -- match the live Hunk window by its current working directory
- `--source <path>` -- load the replacement `diff` / `show` command from a different directory

Use `--source` only for advanced reloads where the live session you want to control is not already associated with the checkout you want to load next. For a normal worktree session, prefer selecting it directly with `--repo /path/to/worktree`.

## Commands

### Inspect

```bash
hunk session list [--json]
hunk session get (--repo . | <id>) [--json]
hunk session context (--repo . | <id>) [--json]
hunk session review (--repo . | <id>) [--json] [--include-patch]
```

- `get` shows the session `Path`, `Repo`, and `Source`, which helps when choosing between `--repo` and `--session-path`
- `Repo` is what `--repo` matches; `Path` is what `--session-path` matches
- `review --json` returns file and hunk structure by default; add `--include-patch` only when a caller truly needs raw unified diff text

### Navigate

Absolute navigation requires `--file` and exactly one of `--hunk`, `--new-line`, or `--old-line`:

```bash
hunk session navigate --repo . --file src/App.tsx --hunk 2
hunk session navigate --repo . --file src/App.tsx --new-line 372
hunk session navigate --repo . --file src/App.tsx --old-line 355
```

Relative comment navigation jumps between annotated hunks and does not require `--file`:

```bash
hunk session navigate --repo . --next-comment
hunk session navigate --repo . --prev-comment
```

- `--hunk <n>` is 1-based
- `--new-line` / `--old-line` are 1-based line numbers on that diff side
- Use either `--next-comment` or `--prev-comment`, not both

### Reload

Swaps the live session's contents. Pass a Hunk review command after `--`:

```bash
hunk session reload --repo . -- diff
hunk session reload --repo . -- diff main...feature -- src/ui
hunk session reload --repo . -- show HEAD~1
hunk session reload --repo . -- show HEAD~1 -- README.md
hunk session reload --repo /path/to/worktree -- diff
hunk session reload --session-path /path/to/live-window --source /path/to/other-checkout -- diff
```

- Always include `--` before the nested Hunk command
- `--repo` or `<session-id>` usually selects the session you want
- `--source` is advanced: it does not select the session; it only changes where the replacement review command runs
- If the live session is already showing the target worktree, prefer `hunk session reload --repo /path/to/worktree -- diff`
- `--session-path` targets the live window when you need to keep session selection separate from reload source

### Comments

```bash
hunk session comment add --repo . --file README.md --new-line 103 --summary "Tighten this wording" [--rationale "..."] [--author "agent"] [--focus]
printf '%s\n' '{"comments":[{"filePath":"README.md","newLine":103,"summary":"Tighten this wording"}]}' | hunk session comment apply --repo . --stdin [--focus]
hunk session comment list --repo . [--file README.md] [--type live|all|ai|agent|user]
hunk session comment rm --repo . <comment-id>
hunk session comment clear --repo . --yes [--file README.md]
```

- `comment list --type user` shows human-authored inline notes; without `--type`, `comment list` preserves the legacy live-agent-comment view
- `comment add` is best for one note; `comment apply` is best when an agent already has several notes ready
- `comment add` requires `--file`, `--summary`, and exactly one of `--old-line` or `--new-line`
- `comment apply` payload items require `filePath`, `summary`, and exactly one target such as `hunk`, `hunkNumber`, `oldLine`, or `newLine`
- `comment apply` reads a JSON batch from stdin and validates the full batch before mutating the live session
- Pass `--focus` when you want to jump to the new note or the first note in a batch
- `comment list` and `comment clear` accept optional `--file`
- Quote `--summary` and `--rationale` defensively in the shell

## New files in working-tree reviews

`hunk diff` includes untracked files by default. If the user wants tracked changes only, reload with `--exclude-untracked`:

```bash
hunk session reload --repo . -- diff --exclude-untracked
```

## Guiding a review

The user may ask you to walk them through a changeset or review code using Hunk. Start with `hunk session review --json` to understand the file/hunk structure without inflating agent context, then use `--include-patch` only for the files you truly need to read in raw diff form. Use `context` and `navigate` to line up the user's current view before adding comments.

Your role is to narrate: steer the user's view to what matters and leave comments that explain what they're looking at.

Typical flow:

1. Load the right content (launch per "Launching Hunk" above if no session exists yet, otherwise `reload` if needed)
2. Navigate to the first interesting file / hunk
3. Add a comment explaining what's happening and why
4. If you already have several notes ready, prefer one `comment apply` batch over many separate shell invocations
5. Summarize when done

Guidelines:

- Work in the order that tells the clearest story, not necessarily file order
- Navigate before commenting so the user sees the code you're discussing
- Use `comment apply` for agent-generated batches and `comment add` for one-off notes
- Use `--focus` sparingly when the note itself should actively steer the review
- Keep comments focused: intent, structure, risks, or follow-ups
- Don't comment on every hunk -- highlight what the user wouldn't spot themselves

## Common errors

- **"No visible diff file matches ..."** -- the file is not in the loaded review. Check `context`, then `reload` if needed.
- **"No active Hunk sessions"** -- launch one yourself per "Launching Hunk" above. If you just did and it's still not showing up, localhost may be blocked by the agent sandbox; retry with network/sandbox escalation.
- **"Multiple active sessions match"** -- pass `<session-id>` explicitly.
- **"No active Hunk session matches session path ..."** -- for advanced split-path reloads, verify the live window `Path` via `hunk session get` or `list`, then use `--session-path`.
- **"Pass the replacement Hunk command after `--`"** -- include `--` before the nested `diff` / `show` command.
- **"Pass --stdin to read batch comments from stdin JSON."** -- `comment apply` only reads its batch payload from stdin.
- **"Specify exactly one navigation target"** -- pick one of `--hunk`, `--old-line`, or `--new-line`.
- **"Specify either --next-comment or --prev-comment, not both."** -- choose one comment-navigation direction.
