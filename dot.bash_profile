# .bash_profile

# shellcheck shell=bash

## Import configuration for non-interactive shells.
if [ -f "${HOME}/.bashrc" ] ; then
    . "${HOME}/.bashrc"
fi

## Interactive shells configuration.

## Pretty colours.
reverse=$(tput rev)
bold=$(tput bold)
noColour=$(tput sgr 0)

black=$(tput setaf 232)
white=$(tput setaf 007)
brown=$(tput setaf 003)
red=$(tput setaf 001)
orange=$(tput setaf 202)
yellow=$(tput setaf 003)
green=$(tput setaf 002)
cyan=$(tput setaf 006)
blue=$(tput setaf 004)
magenta=$(tput setaf 005)
lblue=$(tput setaf 033)

lbluebg=$(tput setab 033)

lred='\e[91m'
lgreen='\e[92m'
yellow='\e[93m'
lpurple='\e[95m'
lcyan='\e[96m'
lgray='\e[37m'
dgray='\e[90m'

dashes="$(s=$(printf "%*s" 3); echo "${s// /―}")"

readonly reverse bold noColour 
readonly black white brown red orange yellow green cyan blue magenta 
readonly lblue lred lgreen yellow lpurple lcyan lgray dgray
readonly lbluebg
readonly dashes

os='unknown'
unamestr=$(uname)
if [ "$unamestr" == "Linux" ]; then
	os='linux'
elif [ "$unamestr" == 'Darwin' ]; then
	os='macos'
fi

case $(hostname) in 
*test*)
  hostColour="${red}"
  ;;
*)
  hostColour="${lpurple}"
  ;;
esac

# User specific aliases and functions

source "${HOME}/.dotfiles/functions/functions.gen"

case "$os" in 
linux)
  . "${HOME}/.dotfiles/functions/functions.linux"
  ;;
macos)
  alias crashreport='vim ~/Documents/Crashes/`date "+%Y%m%d%H%M%S"`.panic'
  alias flushdns='sudo killall -HUP mDNSResponder; sleep 2; echo macOS DNS Cache is reset.'
  alias ls="ls -G"
  . "${HOME}/.dotfiles/functions/functions.osx"
  ;;
esac

alias ls-la='ls -la'
alias v='vagrant'
alias ds='date +%Y%m%d%H%M%S'
alias alldu='du -sck .[!.]* *'
alias dumphttp="sudo tcpdump -A -s 0 'tcp port 80 and (((ip[2:2] - ((ip[0]&0xf)<<2)) - ((tcp[12]&0xf0)>>2)) != 0)'"	
alias dumphttpget="sudo tcpdump -s 0 -A 'tcp[((tcp[12:1] & 0xf0) >> 2):4] = 0x47455420'"
alias dumphttppost="sudo tcpdump -s 0 -A 'tcp dst port 80 and (tcp[((tcp[12:1] & 0xf0) >> 2):4] = 0x504f5354)'"
alias pls='sudo $(history -p \!\!)' 
alias noc='egrep -v "^\s*(#|$)"'
alias grep='grep --colour=always'

# git helpers.
export GIT_PS1_SHOWDIRTYSTATE=yesPlease

# Colour prompt with git status.
case "${TERM}" in 
xterm*|rxvt*)
  TITLEBAR='\[\e]0;\u@\h:\w\a\]'
  PS1="${TITLEBAR}${hostColour}${dashes} ${green}\u${noColour}@${hostColour}\h${noColour}:${lblue}\w ${lgray}(${bold}\j${noColour}${lgray} jobs)${orange}"'$(__git_ps1)'"${noColour}\n\$ "
  ;;
linux|vt*)
  PS1="${green}${dashes} \u${noColour}@${hostColour}\h${noColour}:${lblue}\w ${lgray}(${bold}\j${noColour}${lgray} jobs)${orange}"'$(__git_ps1)'"${noColour}\n\$ "
  ;;
*)
  PS1='\u@\h:\w\$ '
  ;;
esac

PROMPT_COMMAND='ret=$?; if [ $ret -ne 0 ] ; then printf "${white}${lbluebg}${bold}RETURN${noColour}: ${lblue}${ret}${noColour}\n"; fi'

# User specific environment and startup programs
PATH="$PATH:/sbin:/usr/sbin:${HOME}/bin"
VISUAL="/usr/bin/vim"
EDITOR="/usr/bin/vi -e"
GREP_COLORS='fn=1;32'

export PATH VISUAL EDITOR GREP_COLORS PS1 PROMPT_COMMAND

# Check the version of the dot.files and see if it's the latest.
#. "${HOME}/.dotfiles/setup/check_version.sh"

# Include local configurations.
if [ -f "${HOME}/.bash_profile_local" ] ; then
    . "${HOME}/.bash_profile_local"
fi

echo;uptime; echo
