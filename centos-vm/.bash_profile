# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi


parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

lastcmd_status() {
    local exit="$?"
    local green='\[\033[0;32m\]'
    local red='\[\033[0;31m\]'
    local prompt='->'
    if [[ "$exit" == "0" ]]; then
       echo -e "${green}${prompt}"
    else
        echo -e "${red}${prompt}"
    fi
}

# a more fancy ps1
if [ "$PS1" ]; then
    PS1="\[\033[01;31m\]+\[\033[01;33m\]+\[\033[01;32m\]+\[\033[0;36m\]\$(parse_git_branch)\[\033[00m\]\u@\h\[\033[01;34m\] | \W \[\033[0;36m\]-> "
fi

# PS1="[\e[94m\u\e[0m@\e[91m\h\e[0m \e[94m\w\e[0m]\n\e[91m->>\e[0m "

# Connect to network device
nmcli c up enp0s3 > /dev/null 2>&1

# User specific environment and startup programs
PATH=$PATH:$HOME/.local/bin:$HOME/bin

export PATH

# Start new tmux session
tmux_session(){
    local day=$(date | cut -d ' ' -f1) 
    tmux new -s $day > /dev/null 2>&1
}
tmux_session
