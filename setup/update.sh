#!/bin/bash

# this update script will set up the latest changes. or it might not. use at
# your own peril. anyhow, it's just a copy of the functions that I've added 
# to the setup script for whatever I've updated. if there's nothing new to 
# add, then it'll do nothing.

echo "2016-09-29 update."

echo "Adding .inputrc: "

if [[ -e ~/.inputrc ]]; then
	mv ~/.inputrc ~/.inputrc.orig
	echo "moved .gitignore to .gitignore.orig"
fi
ln -s ~/.dotfiles/dot.inputrc ~/.inputrc
echo "done."

echo "All finished. To activate, log out and log back in."
