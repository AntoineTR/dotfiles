# brew
if ! [ -x "$(command -v brew)" ]; then
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi
brew update
brew doctor

# iterm2
brew install --cask iterm2

# dotnet sdk
brew install --cask dotnet-sdk

# NodeJs
brew install node

# tmux / tmuxinator
brew install tmux
brew install tmuxinator

# Neovim
brew install neovim

# PyEnv
# brew install pyenv

# Python 
# pyenv install 3:latest

# PynVim

# pip3 install pynvim
