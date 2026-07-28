#!/usr/bin/env bash
# Resolve the tmux session that should actually host new windows/panes.
#
# Claude Code is normally launched by tmux-claude-session-manager
# (ctrl+a y / ctrl+a u), which runs Claude inside a dedicated background
# session named "<prefix><hash>" (prefix defaults to "claude-") and shows it
# to the user as a floating `tmux display-popup` over their real session.
# `tmux display-message -p '#S'` from inside that popup returns the ephemeral
# claude-* session, not the session the user is actually looking at
# underneath — windows created there would be invisible to the user until
# they dig for them. This resolves the real, outer session so new windows
# land where the user will see them.
#
# Prints the target session name on stdout. Prints a warning to stderr (and
# falls back to the current session) only if no outer session can be found.
set -uo pipefail

prefix="$(tmux show-option -gqv @claude_session_prefix 2>/dev/null)"
prefix="${prefix:-claude-}"

current="$(tmux display-message -p '#S')"

if [[ "$current" != "$prefix"* ]]; then
    # Not inside the Claude popup modal - current session is already correct.
    printf '%s\n' "$current"
    exit 0
fi

# Inside the popup: prefer the origin window the plugin recorded when it
# launched this session (@claude_origin holds a window_id like "@42").
origin="$(tmux show-options -qv -t "$current" @claude_origin 2>/dev/null || true)"
if [ -n "$origin" ]; then
    target="$(tmux display-message -t "$origin" -p '#S' 2>/dev/null || true)"
    if [ -n "$target" ]; then
        printf '%s\n' "$target"
        exit 0
    fi
fi

# Fallback: any attached client whose session is NOT a claude-* popup is the
# outer client (mirrors host_client() in the plugin's list.sh).
host="$(tmux list-clients -F '#{client_name} #{session_name}' 2>/dev/null |
    awk -v p="$prefix" 'index($2, p) != 1 { print $2; exit }')"
if [ -n "$host" ]; then
    printf '%s\n' "$host"
    exit 0
fi

echo "resolve_host_session: could not find an outer session, staying in '$current'" >&2
printf '%s\n' "$current"
