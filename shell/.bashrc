# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Be nice to sysadmins
if [ -f /etc/bashrc ]; then
  source /etc/bashrc
elif [ -f /etc/bash.bashrc ]; then
  source /etc/bash.bashrc
fi

export CLICOLOR=1

export HISTCONTROL=ignoreboth
export HISTSIZE=5000
export HISTIGNORE="clear:bg:fg:cd:cd -:cd ..:exit:date:w:* --help:ls:l:ll:lll"

set -o vi

if [ -f "$HOME/.aliases" ]; then
  source $HOME/.aliases
fi

if [ -f "$HOME/.profile" ]; then
  source $HOME/.profile
fi


# opencode
export PATH=/home/joe/.opencode/bin:$PATH

export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

if [ -f "$HOME/.config/vault-hub.env" ]; then
  set -a
  source "$HOME/.config/vault-hub.env"
  set +a
fi
