#!/usr/bin/env bash

# Make Homebrew available in this script even if it's only wired into a shell
# rc file (or this script gets invoked with `sh` instead of `bash`/`./`)
if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# Everything below refers to ~/dotfiles. The repo may live elsewhere (e.g.
# ~/source/repos/dotfiles), so point ~/dotfiles at wherever this script is.
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ ! -e ~/dotfiles ]; then
    ln -s "$DOTFILES" ~/dotfiles
elif [ "$(cd ~/dotfiles && pwd -P)" != "$DOTFILES" ]; then
    echo "warning: ~/dotfiles points at $(cd ~/dotfiles && pwd -P), not $DOTFILES" >&2
fi

# Package install helpers: brew on macOS, apt elsewhere. apt lists are often
# empty on a fresh machine (WSL images especially), so refresh them once before
# the first install.
apt_updated=0
pkg_install() {
    if command -v brew &>/dev/null; then
        brew install "$@"
    elif command -v apt-get &>/dev/null; then
        if [ "$apt_updated" -eq 0 ]; then
            sudo apt-get update
            apt_updated=1
        fi
        sudo apt-get install -y "$@"
    else
        echo "warning: no brew or apt; install manually: $*" >&2
        return 1
    fi
}
# Install a package only if its command is missing
ensure() { # <command> [package...]
    local cmd="$1"; shift
    command -v "$cmd" &>/dev/null || pkg_install "${@:-$cmd}"
}

# create folders
mkdir -p ~/.tmux/plugins/tpm
mkdir -p ~/.local/bin
mkdir -p ~/.config


# source dotfiles bashrc from the live ~/.bashrc
if ! grep -q 'dotfiles/bash/.bashrc' ~/.bashrc; then
    echo '[ -f ~/dotfiles/bash/.bashrc ] && source ~/dotfiles/bash/.bashrc' >> ~/.bashrc
fi

# ~/.bashrc is only read by non-login shells. Terminal.app, kitty (`bash -l`)
# and WSL launch login shells, which read ~/.bash_profile instead - and once
# that file exists bash ignores ~/.profile entirely. Ubuntu's ~/.profile is
# what puts ~/.local/bin on PATH and sources ~/.bashrc, so prefer it when
# present and fall back to ~/.bashrc directly (macOS has no ~/.profile).
if ! grep -q '\.bashrc' ~/.bash_profile 2>/dev/null; then
    echo 'if [ -f ~/.profile ]; then source ~/.profile; elif [ -f ~/.bashrc ]; then source ~/.bashrc; fi' >> ~/.bash_profile
fi

# add symlink .tmux
rm -rf ~/.tmux.conf
ln -s ~/dotfiles/tmux/.tmux.conf ~/.tmux.conf

# add symlinks for bin scripts
ln -sf ~/dotfiles/bin/claude-usage ~/.local/bin/claude-usage
ln -sf ~/dotfiles/bin/tmux-sessions ~/.local/bin/tmux-sessions
ln -sf ~/dotfiles/bin/osc52-copy ~/.local/bin/osc52-copy
ln -sf ~/dotfiles/bin/claude-popup-toggle ~/.local/bin/claude-popup-toggle
chmod +x ~/dotfiles/bin/claude-usage ~/dotfiles/bin/tmux-sessions ~/dotfiles/bin/osc52-copy ~/dotfiles/bin/claude-popup-toggle

# add symlink for the hunk-review Claude Code skill (forked from the hunkdiff npm
# package's bundled skill, with tmux-popup-aware launch behavior added)
mkdir -p ~/.claude/skills
rm -rf ~/.claude/skills/hunk-review
ln -s ~/dotfiles/.claude/skills/hunk-review ~/.claude/skills/hunk-review

# add symlink for the pr-review skill (opens a GitHub PR in Hunk and annotates
# it). Depends on hunk-review above for resolve_host_session.sh
rm -rf ~/.claude/skills/pr-review
ln -s ~/dotfiles/.claude/skills/pr-review ~/.claude/skills/pr-review
chmod +x ~/dotfiles/.claude/skills/pr-review/scripts/open_pr_review.sh

# add symlink kitty config
mkdir -p ~/.config/kitty
rm -rf ~/.config/kitty/kitty.conf
ln -s ~/dotfiles/kitty/kitty.conf ~/.config/kitty/kitty.conf

# mosh - use instead of ssh for roaming/high-latency connections
ensure mosh

# Neovim + what the config needs at runtime:
#   git, curl, unzip  - lazy.nvim and mason.nvim download plugins/servers
#   gcc               - nvim-treesitter compiles parsers (prisma)
#   node/npm          - vtsls (via mason) and copilot.lua
#   ripgrep           - telescope live_grep
#   lazygit           - lazygit.nvim
ensure nvim neovim
ensure git
ensure curl
ensure unzip
if command -v brew &>/dev/null; then
    ensure gcc
    ensure node
else
    ensure gcc build-essential
    ensure node nodejs npm
fi
ensure rg ripgrep
ensure lazygit

# add symlink nvim (the whole directory; lazy.nvim expects init.lua + lua/ as
# one tree). Keep a copy of any pre-existing real config rather than deleting it.
if [ -e ~/.config/nvim ] && [ ! -L ~/.config/nvim ]; then
    mv ~/.config/nvim ~/.config/nvim.bak.$(date +%Y%m%d%H%M%S)
fi
rm -f ~/.config/nvim
ln -s ~/dotfiles/nvim ~/.config/nvim

# add symlink dotfiles project
# rm -rf ~/.config/tmuxinator/dotfiles.yml
# ln -s ~/dotfiles/dotfiles.yml ~/.config/tmuxinator/dotfiles.yml

# sqlit - TUI for SQL databases (https://github.com/Maxteabag/sqlit)
if ! command -v pipx &>/dev/null; then
    if command -v brew &>/dev/null; then
        brew install pipx
        pipx ensurepath
    elif command -v apt-get &>/dev/null; then
        pkg_install pipx
    else
        python3 -m pip install --user pipx
        python3 -m pipx ensurepath
        export PATH="$PATH:$HOME/.local/bin"
    fi
fi
pipx install sqlit-tui || echo "warning: sqlit-tui install failed (already installed, or no wheel for this Python); continuing" >&2

# tmux itself (needed for the plugin install and source-file below)
ensure tmux

#Plugin manager for Tmux

rm -rf ~/.tmux/plugins/tpm

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Install the plugins listed in .tmux.conf (dracula, claude-session-manager)
# now instead of waiting for prefix+I. tpm's installer starts its own
# throwaway server, so this works with no tmux running.
~/.tmux/plugins/tpm/bin/install_plugins

# Reload the config into a running server, if there is one
if tmux list-sessions &>/dev/null; then
    tmux source-file ~/.tmux.conf
fi
