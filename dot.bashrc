# .bashrc

black='\e[30m'
red='\e[31m'
green='\e[32m'
brown='\e[33m'
blue='\e[34m'
magenta='\e[35m'
cyan='\e[36m'
lgray='\e[37m'
dgray='\e[90m'
lred='\e[91m'
lgreen='\e[92m'
yellow='\e[93m'
lblue='\e[94m'
lpurple='\e[95m'
lcyan='\e[96m'
white='\e[97m'
dashes="\$(s=\$(printf "%*s" 3); echo \${s// /―})"

noColour='\e[0m'

platform='unknown'
unamestr=`uname`
if [[ "$unamestr" == "Linux" ]]; then
	platform='linux'
elif [[ "$unamestr" == 'Darwin' ]]; then
	platform='osx'
fi

case `hostname` in 
stan*)
	hostColour="${cyan}"
	;;
tardis*)
	hostColour="${brown}"
	;;
dexter*)
	hostColour="${yellow}"
	;;
*test*)
    hostColour="${red}"
    ;;
*)
	hostColour="${lpurple}"
	;;
esac

# Source global definitions
if [ -f /etc/bash.bashrc ]; then
	. /etc/bash.bashrc
fi

# User specific aliases and functions
source ~/.git-completion
source ~/.git-prompt
source ~/.dotfiles/functions/functions.gen

case "$platform" in 
linux)
	. ~/.dotfiles/functions/functions.linux
	;;
osx)
	alias crashreport='vim ~/Documents/Crashes/`date "+%Y%m%d%H%M%S"`.panic'
	alias flushdns='sudo killall -HUP mDNSResponder'
	. ~/.dotfiles/functions/functions.osx
	;;
esac

alias ls-la='ls -la'
alias v='vagrant'
alias ds='date +%Y%m%d%H%M%S'
alias alldu='du -sck .[!.]* *'
alias dumphttp="sudo tcpdump -A -s 0 'tcp port 80 and (((ip[2:2] - ((ip[0]&0xf)<<2)) - ((tcp[12]&0xf0)>>2)) != 0)'"	
alias dumphttpget="sudo tcpdump -s 0 -A 'tcp[((tcp[12:1] & 0xf0) >> 2):4] = 0x47455420'"
alias dumphttppost="sudo tcpdump -s 0 -A 'tcp dst port 80 and (tcp[((tcp[12:1] & 0xf0) >> 2):4] = 0x504f5354)'"
alias sigh='sudo $(history -p \!\!)' 
alias noc='egrep -v "^\s*(#|$)"'
alias grep='grep --colour=always'

# git helpers.
export GIT_PS1_SHOWDIRTYSTATE=yesPlease

# Colour prompt with git status.
case "${TERM}" in 
xterm*|rxvt*)
	TITLEBAR='\[\e]0;\u@\h:\w\a\]'
	PS1="${TITLEBAR}${hostColour}${dashes} ${green}\u${noColour}@${hostColour}\h${noColour}:${lblue}\w ${lgray}(\j jobs)${lred}"'$(__git_ps1)'"${noColour}\n\$ "
	;;
linux|vt*)
	PS1="${green}${dashes} \u${noColour}@${hostColour}\h${noColour}:${lblue}\w ${lgray}(\j jobs)${lred}"'$(__git_ps1)'"${noColour}\n\$ "
	;;
*)
	PS1='\u@\h:\w\$ '
	;;
esac

# SSH agent set up.
SSH_ENV="${HOME}/.ssh/environment"

#function start_agent {
#	echo "Initialising new SSH agent..."
#	/usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
#	echo succeeded
#	chmod 600 "${SSH_ENV}"
#	. "${SSH_ENV}" > /dev/null
#	/usr/bin/ssh-add;
#}

## Source SSHS settings if application.
#if [ -f "${SSH_ENV}" ]; then
#	. "${SSH_ENV}" > /dev/null
#	ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
#		start_agent
#	}
#else
#	start_agent
#fi

# User specific environment and startup programs
PATH=$PATH:/sbin:/usr/sbin:${HOME}/bin
VISUAL="/usr/bin/vim"
EDITOR="/usr/bin/vi -e"
GREP_COLORS='fn=1;32'

PROMPT_COMMAND='ret=$?; if [ $ret -ne 0 ] ; then echo -e "\033[1m\x1B[37;44mRETURN:\033[0m \033[01;34m$ret\033[00;00m"; fi'

# Include any local configurations.
if [ -f ~/.bash_local ]
then 
    . ~/.bash_local
fi

export PS1 PATH VISUAL EDITOR PROMPT_COMMAND GREP_COLORS
