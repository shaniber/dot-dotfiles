# .bash_profile

# shellcheck shell=bash

# If not running interactively, don't do anything
# Ref: https://github.com/skx/dotfiles/blob/master/.bash_profile
[ -z "$PS1" ] && return

## Import configuration for non-interactive shells.
if [ -f "${HOME}/.bashrc" ] ; then
    source "${HOME}/.bashrc"
fi

## Interactive shells configuration.

### Pretty colours!
source "${HOME}/.dotfiles/colours.sh"

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

case "${USER}" in
administrator)
  userColour="${reverse}${red}"
  ;;
ssd|shaned|shanedoucette|shane.doucette)
  userColour="${green}"
  ;;
*)
  userColour="${cyan}"
  ;;
esac

# User specific aliases and functions
source "${HOME}/.dotfiles/functions/functions.gen"

case "$os" in 
linux)
  source "${HOME}/.dotfiles/functions/functions.linux"
  ;;
macos)
  # Hide the “default interactive shell is now zsh” warning on macOS.
  export BASH_SILENCE_DEPRECATION_WARNING=1;

  # More convenient ls colours. 
  export LSCOLORS=gxfxcxdxbxegedabagaced

  alias ssidname='system_profiler SPAirPortDataType | awk '\''/Current Network Information:/{getline; print $1; exit}'\'' | sed '\''s/:.*//'\'' | awk '\''{$1=$1};1'\''' 
  alias crashreport='vim ~/Documents/Crashes/`date "+%Y%m%d%H%M%S"`.panic'
  alias flushdns='sudo killall -HUP mDNSResponder; sleep 2; echo macOS DNS Cache is reset.'
  alias ls="ls -G"
  source "${HOME}/.dotfiles/functions/functions.macos"
  ;;
esac

alias ls-la='ls -la'
alias ds='date +%Y%m%d%H%M%S'
alias alldu='du -sck .[!.]* *'
alias dumphttp="sudo tcpdump -A -s 0 'tcp port 80 and (((ip[2:2] - ((ip[0]&0xf)<<2)) - ((tcp[12]&0xf0)>>2)) != 0)'"	
alias dumphttpget="sudo tcpdump -s 0 -A 'tcp[((tcp[12:1] & 0xf0) >> 2):4] = 0x47455420'"
alias dumphttppost="sudo tcpdump -s 0 -A 'tcp dst port 80 and (tcp[((tcp[12:1] & 0xf0) >> 2):4] = 0x504f5354)'"
alias pls='sudo $(history -p \!\!)' 
alias noc='/usr/bin/egrep -v "^\s*(#|$)"'
alias grep='/usr/bin/grep --colour=always'
alias rand='/usr/bin/head -c4 /dev/urandom | /usr/bin/od -An -vtu4'
alias urlcheck='/usr/bin/curl -I -o /dev/null --silent --write-out '\''%{http_code}\n'\'''

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
VISUAL="/usr/bin/vim"
EDITOR="/usr/bin/vi"
GREP_COLORS='fn=1;32'


# Check the version of the dot.files and see if it's the latest.
#source "${HOME}/.dotfiles/setup/check_version.sh"

# Include local configurations.
if [ -f "${HOME}/.bash_profile_local" ] ; then
    source "${HOME}/.bash_profile_local"
fi

export PATH VISUAL EDITOR GREP_COLORS PS1 PROMPT_COMMAND

echo ; uptime ; echo

