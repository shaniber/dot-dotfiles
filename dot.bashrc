# .bashrc

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
export PS1='\[\033[32m\]\u\[\033[00m\]@\[\033[36m\]\h\[\033[00m\]:\[\033[34m\]\w\[\033[31m\]$(__git_ps1)\[\033[00m\]\$ '

# User specific environment and startup programs
PATH=$PATH:$HOME/bin
VISUAL="/usr/bin/vim"
EDITOR="/usr/bin/vi -e"
export PATH VISUAL EDITOR
