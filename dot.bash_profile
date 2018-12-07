# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs
PATH=$PATH:$HOME/bin
export PATH

# Check the version of the dot.files and see if it's the latest.
. ~/.dotfiles/setup/check_version.sh

echo;uptime; echo

export PATH="$HOME/.cargo/bin:$PATH"
