# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Be nice to sysadmins
if [ -f /etc/bashrc ]; then
  source /etc/bashrc
elif [ -f /etc/bash.bashrc ]; then
  source /etc/bash.bashrc
fi

export PATH=$PATH:$HOME/.local/bin

# History management
export HISTCONTROL=ignoreboth
export HISTSIZE=5000
export HISTIGNORE="clear:bg:fg:cd:cd -:cd ..:exit:date:w:* --help:ls:l:ll:lll"

export FZF_BIN="$(which fzf)"
if type rg &> /dev/null; then
  export FZF_DEFAULT_COMMAND='rg --files --ignore-vcs --hidden'
  export FZF_DEFAULT_OPTS='-m --height 50% --border'
fi
eval "$(fzf --bash)"

set -o vi
