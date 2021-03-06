# vim and tmux
alias v='nvim'
alias nv='nvim'
alias tmux="tmux -f ~/.config/nvim/.tmux.conf"
alias dot='nvim ~/dotfiles'

# python3
alias python='python3'

# shortcuts
alias c='clear'
alias b='cd ..'
alias x='exit'
alias ls='ls -G'
alias h='cd ~ && clear'
alias src='source ~/.bash_profile'
alias pi='ssh raspberrypi.local -l pi'

# git
alias g='git'
alias gaa='git add -A'
alias gb="git branch | grep -v 'zz-'" # I prefix stale branches I want to keep with zz-
alias gbd='git branch -D'
alias gs='git status'
alias gdiff='git diff staging...HEAD'
alias gl='pretty_git_log'
alias gv='git diff --name-only | uniq | xargs nvim'
