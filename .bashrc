# Exports
export EDITOR='nvim'
export ASPNETCORE_ENVIRONMENT=Development
# Common aliases
alias r='exec /bin/bash'
alias ll='ls -la'
alias vim='nvim'
alias tmux='tmux -2'
alias uuid='node -e "var UUIDv4 = function b(a){return a?(a^Math.random()*16>>a/4).toString(16):([1e7]+-1e3+-4e3+-8e3+-1e11).replace(/[018]/g,b)};console.log(UUIDv4());"'
alias mux='tmuxinator'
alias flushdns='sudo killall -HUP mDNSResponder;sudo killall mDNSResponderHelper;sudo dscacheutil -flushcache'

# Git
alias gs='git status'
alias gc='git commit'

# GetShitDone
alias gsd='sudo ~/dotfiles/getshitdone/get-shit-done.sh'
alias gsdw='sudo ~/dotfiles/getshitdone/get-shit-done.sh work'
alias gsdp='sudo ~/dotfiles/getshitdone/get-shit-done.sh play'

#What's my IP
alias myip='curl ifconfig.me'
[ -z "$ZSH_NAME" ] && [ -f ~/.fzf.bash ] && source ~/.fzf.bash