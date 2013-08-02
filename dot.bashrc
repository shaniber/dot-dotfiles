# .bashrc

red='\e[31m'
green='\e[32m'
yellow='\e[33m'
blue='\e[34m'
magenta='\e[35m'
cyan='\e[36m'
lred='\e[91m'
lpurple='\e[95m'
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
PROMPT="${green}\u${noColour}@${hostColour}\h${noColour}:${blue}\w${lred}$(__git_ps1)${noColour}\$"
case "${TERM}" in 
xterm*|rxvt*)
	PS1="${TITLEBAR}${PROMPT} "
	;;
linux)
	PS1="${PROMPT} "
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
