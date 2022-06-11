source ~/dotfiles/git/index.sh
source ~/dotfiles/.bash_aliases

__git_complete g __git_main
__git_complete gc _git_checkout
__git_complete gco _git_checkout
__git_complete gm _git_merge
__git_complete gp _git_pull

export PS1="\h \[\033[34m\]\W\[\033[32m\]\$(parse_git_branch)\[\033[00m\] \j $ "
export FZF_DEFAULT_COMMAND='ag --nocolor --ignore node_modules -g ""'

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
PATH="/usr/local/bin:$PATH"
PATH="${PATH}:~/.vimpkg/bin"
## Java/Maven
PATH="${JAVA_HOME}/bin:$PATH"
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
PATH="/usr/local/opt/mongodb@3.4/bin:$PATH"
# Rust/Cargo
PATH="$HOME/.cargo/bin:$PATH"
# Python
PATH="/Library/Frameworks/Python.framework/Versions/3.5/bin:${PATH}"
PATH="/Library/Frameworks/Python.framework/Versions/3.7/bin:${PATH}"
export PATH

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/$(whoami)/google-cloud-sdk/path.bash.inc' ]; then . '/Users/$(whoami)/google-cloud-sdk/path.bash.inc'; fi
# The next line enables shell command completion for gcloud.
if [ -f '/Users/$(whoami)/google-cloud-sdk/completion.bash.inc' ]; then . '/Users/$(whoami)/google-cloud-sdk/completion.bash.inc'; fi

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

echo -e "\e[36mnode version:\e[0m $(node --version)"
echo -e "\e[35mruby version:\e[0m $(ruby --version)"
echo -e "\e[32mpython version:\e[0m $(python --version)"
. "$HOME/.cargo/env"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/tom/opt/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/tom/opt/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/tom/opt/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/tom/opt/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

