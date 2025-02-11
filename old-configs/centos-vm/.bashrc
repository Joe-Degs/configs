# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

if [ -f ~/.bash_aliases ]; then
    source ~/.bash_aliases
fi

# enable gruvbox 256 color palette
# source "$HOME/.vim/pack/default/start/gruvbox/gruvbox_256palette.sh"

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# Useful functions
mcd() {
    mkdir $1
    cd $1
}

# currently having lots of trouble accessing the docs for golang.org/x/* files
# beacause go doc uses go modules and i can only have the documentation
# if i have them them included in my go.mod file. So this functions help me
# access the docs for x packages from anywhere on this box.
gxls() {
    ls ~/go/src/golang.org/x/"$1"
}

gxd() {
    go doc ~/go/src/golang.org/x/"$1"/"$2"
}

# Bash env virables
export PATH=$PATH:/usr/local/go/bin
export GOPATH=~/go
export PATH=$PATH:$GOPATH/bin

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

if type rg &> /dev/null; then
  export FZF_DEFAULT_COMMAND='rg --files'
  export FZF_DEFAULT_OPTS='-m --height 50% --border'
fi

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
