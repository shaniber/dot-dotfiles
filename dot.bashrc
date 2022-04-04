# .bashrc

# shellcheck shell=bash

# Source global definitions
if [ -f /etc/bash.bashrc ]; then
	. /etc/bash.bashrc
fi

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

## Source SSH settings if applicable.
#if [ -f "${SSH_ENV}" ]; then
#	. "${SSH_ENV}" > /dev/null
#	ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
#		start_agent
#	}
#else
#	start_agent
#fi

export SSH_ENV

# Include any local configurations.
if [ -f ~/.bash_local ]
then 
    . ~/.bash_local
fi
