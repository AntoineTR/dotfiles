#!/usr/bin/env bash


# create folders
mkdir -p ~/.config/nvim/{plugin,after/plugin,lua/leantoinetr,ftplugin}
mkdir -p ~/.config/tmuxinator
mkdir -p ~/.tmux/plugins/tpm


# add symlink .bashrc
rm -rf ~/.bashrc
ln -s ~/dotfiles/bash/.bashrc ~/.bashrc
rm -rf ~/.bash_profile
ln -s ~/dotfiles/bash/.bash_profile ~/.bash_profile

# add symlink .tmux
rm -rf ~/.tmux.conf
ln -s ~/dotfiles/tmux/.tmux.conf ~/.tmux.conf

# add symlink nvim
for f in `find nvim/ -regex ".*\.vim$\|.*\.lua$"`; do
    rm -rf ~/.config/$f
    ln -s ~/dotfiles/$f ~/.config/$f
done
# add symlink dotfiles project
rm -rf ~/.config/tmuxinator/dotfiles.yml
ln -s ~/dotfiles/dotfiles.yml ~/.config/tmuxinator/dotfiles.yml

#Plugin manager for Tmux

rm -rf ~/.tmux/plugins/tpm

#git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

#tmux source-file ~/.tmux.conf
