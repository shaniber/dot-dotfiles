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

# Source global definitions
if [ -f /etc/bash.bashrc ]; then
	. /etc/bash.bashrc
fi

# User specific aliases and functions
source ~/.git-completion
source ~/.git-prompt

# (yes, it's because I'm a clumsy typist)
alias ls-la='ls -la'

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

# User specific environment and startup programs
PATH=$PATH:$HOME/bin
VISUAL="/usr/bin/vim"
EDITOR="/usr/bin/vi -e"

PROMPT_COMMAND='ret=$?; if [ $ret -ne 0 ] ; then echo -e "\033[1m\E[47;41mERROR:\033[0m \033[01;31m$ret\033[00;00m"; fi'

export PS1 PATH VISUAL EDITOR PROMPT_COMMAND
