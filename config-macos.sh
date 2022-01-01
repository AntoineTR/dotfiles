# MACOS Configs

# No sleep
sudo pmset -a sleep 0
sudo pmset -a hibernatemode 0 
sudo pmset -a disablesleep 1

#Name
sudo scutil --set ComputerName "antoine-mbp" # set hostname
sudo scutil --set HostName "antoine-mbp"
sudo scutil --set LocalHostName "antoine-mbp"

#Screen saver
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 10

#Finder
defaults write -g AppleShowAllExtensions -bool true
defaults write com.apple.finder AppleShowAllFiles true 
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv" # list view is default
defaults write com.apple.finder WarnOnEmptyTrash -bool false 
defaults write com.apple.finder QuitMenuItem -bool true # quit finder with ⌘ + Q
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf" # Use current directory as default search scope in Finder
defaults write com.apple.finder ShowPathbar -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true

# Keyboard
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3 # allow tab in popups
defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false # disable spelling correction

defaults write NSGlobalDomain KeyRepeat -int 2 
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Mouse

defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
defaults write com.apple.AppleMultitouchTrackpad Clicking -int 1

# Battery 
defaults write com.apple.menuextra.battery ShowPercent -string "NO"
defaults write com.apple.menuextra.battery ShowTime -string "YES"

#Corner
defaults write com.apple.dock wvous-tr-corner -int 13 # lock
defaults write com.apple.dock wvous-tr-modifier -int 13 # add option modifier to corner

# Dock
defaults write com.apple.dock tilesize -int 32 # dock icon size
defaults write com.apple.dock expose-animation-duration -float 0.1 # faster dock anim.


for app in Safari Finder Dock Mail SystemUIServer; do killall "$app" >/dev/null 2>&1; done
