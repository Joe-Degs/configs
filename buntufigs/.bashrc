
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
elif [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi


# change terminal prompt text to this obscene sh!t
# export PS1='\[\033[0;35m\]+++ \h\[\033[1;32m\]:: '
#

# display git branch when in git repository.
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

# change ps1
if [ "$PS1" ]; then
    PS1="\[\033[0;31m\]+\[\033[01;33m\]+\[\033[0;32m\]+ \[\033[38;5;65m\]\$(parse_git_branch) \[\033[38;5;58m\]\u \[\033[38;5;94m\][ \W |->>\[\033[38;5;59m\] "
fi

# golang path variable
export PATH=$PATH:/usr/local/go/bin
export GOPATH=~/go
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:$HOME/.cargo/bin


# Rust env variable
source "$HOME/.cargo/env"

#source <(kubectl completion bash)

# change defualt pager
export PAGER="most"

# gruvbox support
source "$HOME/.vim/pack/default/start/gruvbox/gruvbox_256palette.sh"
export TERM="xterm-256color"

# func for new tmux sessions.
tplex() {
	tmux new -s $(date | cut -d ' ' -f1)
}

# start tmux on startup.
tplex 2> /dev/null
