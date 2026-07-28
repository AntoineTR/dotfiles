# Homebrew (installer only wires this into ~/.zprofile by default, but we use bash)
if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# Exports
export EDITOR='nvim'
export ASPNETCORE_ENVIRONMENT=Development
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export PATH="$PATH:$HOME/.dotnet/tools"

# Common aliases
alias r='exec /bin/bash'
alias ll='ls -la'
alias vim='nvim'
tmux() { command tmux -2 attach 2>/dev/null || command tmux -2 "$@"; }
alias uuid='node -e "var UUIDv4 = function b(a){return a?(a^Math.random()*16>>a/4).toString(16):([1e7]+-1e3+-4e3+-8e3+-1e11).replace(/[018]/g,b)};console.log(UUIDv4());"'
alias mux='tmuxinator'
alias flushdns='sudo killall -HUP mDNSResponder;sudo killall mDNSResponderHelper;sudo dscacheutil -flushcache'

# Git
alias gs='git status'
alias gc='git commit'
alias ga='git add .'
alias gp='git push'

# GetShitDone
alias gsd='sudo ~/tools/get-shit-done/get-shit-done.sh'
alias gsdw='sudo ~/tools/get-shit-done/get-shit-done.sh work'
alias gsdp='sudo ~/tools/get-shit-done/get-shit-done.sh play'

#Wttr
alias wttr='curl wttr.in'

#What's my IP
alias myip='curl ifconfig.me'
[ -z "$ZSH_NAME" ] && [ -f ~/.fzf.bash ] && source ~/.fzf.bash

# auto-attach to tmux on SSH (also fires for mosh, which inherits a stale
# SSH_CONNECTION from its bootstrap handshake) — the client's local shell no
# longer wraps itself in tmux (see kitty/kitty.conf), so this is the only
# tmux layer and always lives on the server being connected to.
if [ -z "$TMUX" ] && [ -n "$SSH_CONNECTION" ]; then
    tmux attach-session 2>/dev/null || tmux new-session
fi
