# brew
if ! [ -x "$(command -v brew)" ]; then
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi
brew update
brew doctor

# iterm2
brew list iterm2 || brew --cask iterm2

# dotnet sdk
brew list dotnet-sdk || brew install --cask dotnet-sdk
## used by lsp-config for NEOVIM
dotnet tool install --global csharp-ls

# NodeJs
brew list node || brew install node

# Angular 
npm install -g @angular/cli
npm install -g @angular/language-server

# TypeScript
npm install -g typescript typescript-language-server

# tmux / tmuxinator
brew list tmux || brew install tmux 
brew list tmuxinator || brew install tmuxinator
 

# Neovim
brew list neovim || brew install neovim

# FiraCode Fonts

brew tap homebrew/cask-fonts
brew list font-fira-code || brew install font-fira-code 
brew list font-fira-mono || brew install font-fira-mono
brew list font-fira-sans || brew install font-fira-sans
