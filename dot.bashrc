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

noColour='\e[0m'

case `hostname` in 
gallifrey*)
	hostColour="${cyan}"
	;;
tardis*)
	hostColour="${brown}"
	;;
dexter*)
	hostColour="${yellow}"
	;;
*)
	hostColour="${lpurple}"
	;;
esac

echo -e ${hostColour}
echo "  Welcome, ${USER}!"

# Source global definitions
if [ -f /etc/bash.bashrc ]; then
	. /etc/bash.bashrc
fi

# User specific aliases and functions
source ~/.git-completion
source ~/.git-prompt


# git helpers.
export GIT_PS1_SHOWDIRTYSTATE=yesPlease

# Colour prompt with git status.
TITLEBAR='\[\e]0;\u@\h:\w\a\]'
case "${TERM}" in 
xterm*|rxvt*)
	PS1="${TITLEBAR}${green}\u${noColour}@${hostColour}\h${noColour}:${blue}\w${lred}"'$(__git_ps1)'"${noColour}\$ "
	;;
linux)
	PS1="${green}\u${noColour}@${hostColour}\h${noColour}:${blue}\w${lred}"'$(__git_ps1)'"${noColour}\$ "
	;;
*)
	PS1='\u@\h:\w\$ '
	;;
esac
export PS1

# User specific environment and startup programs
PATH=$PATH:$HOME/bin
VISUAL="/usr/bin/vim"
EDITOR="/usr/bin/vi -e"
export PATH VISUAL EDITOR

echo -e ${noColour}
