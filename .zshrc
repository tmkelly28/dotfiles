source ~/dotfiles/zsh/omz.zsh
source ~/dotfiles/.zsh_aliases
source ~/dotfiles/git/gpo.sh
source ~/dotfiles/git/pretty_git_logs.sh

local prompt_jobs="%(1j.%{$fg[green]%}✦%{$reset_color%} .)"
PROMPT+='${prompt_jobs}'

export FZF_DEFAULT_COMMAND='ag --nocolor --ignore node_modules -g ""'
export KEYTIMEOUT=1 # key timeout for vi-mode
export MANPAGER="sh -c 'col -bx | bat -l man -p'" # use bat for man pages

export GIT_EDITOR='nvim'
export REACT_EDITOR='nvim'
export EDITOR='nvim'
export NODE_ENV='development'

export GOPATH="/Users/$(whoami)/go"
export GOBIN="${GOPATH}/bin"
export JAVA_HOME=$(/usr/libexec/java_home)
export ANDROID_HOME=~/Library/Android/sdk
export M2_HOME=/usr/local/Cellar/maven/3.5.0/libexec
export M2=${M2_HOME}/bin

# Path
PATH="/usr/local/bin:${PATH}"
PATH="${PATH}:~/.vimpkg/bin"
## Java/Maven
PATH="${JAVA_HOME}/bin:${PATH}"
PATH="${PATH}:${M2_HOME}/bin"
# Postgres
PATH="${PATH}:/Applications/Postgres.app/Contents/Versions/latest/bin"
# Android
PATH="${PATH}:/Users/$(whoami)/Library/Android/sdk/platform-tools"
PATH="${PATH}:/Applications/Android\ Studio.app/sdk/platform-tools:/Applications/Android\ Studio.app/sdk/tools"
PATH="${PATH}:${ANDROID_HOME}/tools"
# Go
PATH="${PATH}:/Users/$(whoami)/go/bin"
# MongoDb
PATH="/usr/local/opt/mongodb@3.4/bin:${PATH}"
# Rust/Cargo
PATH="${HOME}/.cargo/bin:${PATH}"
# Python
PATH="/Library/Frameworks/Python.framework/Versions/3.5/bin:${PATH}"
PATH="/Library/Frameworks/Python.framework/Versions/3.7/bin:${PATH}"
PATH="/Users/$(whoami)/Library/Python/3.7/bin:${PATH}"
# Ruby/RVM
PATH="${PATH}:${HOME}/.rvm/bin"
export PATH

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/$(whoami)/google-cloud-sdk/path.bash.inc' ]; then . '/Users/$(whoami)/google-cloud-sdk/path.bash.inc'; fi
# The next line enables shell command completion for gcloud.
if [ -f '/Users/$(whoami)/google-cloud-sdk/completion.bash.inc' ]; then . '/Users/$(whoami)/google-cloud-sdk/completion.bash.inc'; fi

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# git config
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.m merge
git config --global alias.a add
git config --global core.excludesfile '~/.gitignore_global'

source ~/dotfiles/.zsh-local.zsh

echo -e "\e[36mnode version:\e[0m $(node --version)"
echo -e "\e[35mruby version:\e[0m $(ruby --version)"
echo -e "\e[32mpython version:\e[0m $(python --version)"
