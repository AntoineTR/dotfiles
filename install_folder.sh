#!/usr/bin/env bash


# create folders
# mkdir -p ~/.config/nvim/{plugin,after/plugin,ftplugin}
# mkdir -p ~/.config/tmuxinator
mkdir -p ~/.tmux/plugins/tpm
mkdir -p ~/.local/bin


# source dotfiles bashrc from the live ~/.bashrc
if ! grep -q 'dotfiles/bash/.bashrc' ~/.bashrc; then
    echo '[ -f ~/dotfiles/bash/.bashrc ] && source ~/dotfiles/bash/.bashrc' >> ~/.bashrc
fi

# add symlink .tmux
rm -rf ~/.tmux.conf
ln -s ~/dotfiles/tmux/.tmux.conf ~/.tmux.conf

# add symlinks for bin scripts
ln -sf ~/dotfiles/bin/claude-usage ~/.local/bin/claude-usage
ln -sf ~/dotfiles/bin/tmux-sessions ~/.local/bin/tmux-sessions
chmod +x ~/dotfiles/bin/claude-usage ~/dotfiles/bin/tmux-sessions

# add symlink for the hunk-review Claude Code skill (forked from the hunkdiff npm
# package's bundled skill, with tmux-popup-aware launch behavior added)
mkdir -p ~/.claude/skills
rm -rf ~/.claude/skills/hunk-review
ln -s ~/dotfiles/.claude/skills/hunk-review ~/.claude/skills/hunk-review

# add symlink kitty config
mkdir -p ~/.config/kitty
rm -rf ~/.config/kitty/kitty.conf
ln -s ~/dotfiles/kitty/kitty.conf ~/.config/kitty/kitty.conf

# mosh - use instead of ssh for roaming/high-latency connections
if ! command -v mosh &>/dev/null; then
    if command -v brew &>/dev/null; then
        brew install mosh
    elif command -v apt &>/dev/null; then
        sudo apt install -y mosh
    fi
fi

# add symlink nvim
# for f in `find nvim/ -name "*.vim" -o -name "*.lua"`; do
#     rm -rf ~/.config/$f
#     ln -s ~/dotfiles/$f ~/.config/$f
# done
# add symlink dotfiles project
# rm -rf ~/.config/tmuxinator/dotfiles.yml
# ln -s ~/dotfiles/dotfiles.yml ~/.config/tmuxinator/dotfiles.yml

# sqlit - TUI for SQL databases (https://github.com/Maxteabag/sqlit)
if ! command -v pipx &>/dev/null; then
    if command -v apt &>/dev/null; then
        sudo apt install -y pipx
    else
        python3 -m pip install --user pipx --break-system-packages
        python3 -m pipx ensurepath
        export PATH="$PATH:$HOME/.local/bin"
    fi
fi
pipx install sqlit-tui

#Plugin manager for Tmux

rm -rf ~/.tmux/plugins/tpm

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

tmux source-file ~/.tmux.conf
