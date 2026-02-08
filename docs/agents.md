# Agents

This repo contains personal dotfiles and setup scripts for multiple environments (macOS, Linux, shells, editors, terminal apps). Use this as a practical guide for AI agents working here.

## Project context
- Purpose: Manage and apply configuration for shells, terminal emulators, editors, and related tooling.
- Environments: Primarily macOS and Linux.
- Typical areas: `bash/`, `zsh/` (if present), `nvim/`, `tmux/`, `alacritty/`, `iterm/`, and setup scripts at repo root.

## How to work in this repo
- Prefer minimal, targeted changes. Dotfiles are sensitive; avoid broad refactors unless asked.
- Read before editing: open the relevant config file and any included files it sources.
- Preserve formatting and conventions (indentation, ordering, comments).
- When adding new config, consider cross-platform implications.
- Avoid introducing dependencies unless explicitly requested.

## Common workflows
- macOS setup: `setup-macos.sh` and `config-macos.sh` may be involved.
- Linux setup: check `linux/` for scripts and configs.
- Shell config: `bash/` and other shell-related folders.
- Editor config: `nvim/` for Neovim settings.
- Terminal config: `alacritty/`, `iterm/`, and `tmux/`.

## Testing/verification (lightweight)
- For shell edits, run a login shell or source the file after changes.
- For editor/terminal config, reload the app or restart the relevant process.
- Keep verification steps small and local unless asked for full testing.

## Notes for agents
- If you change behavior, explain the impact clearly in your final response.
- If you notice unrelated changes, stop and ask how to proceed.
- Record any issues you run into in `docs/problems.md`.
