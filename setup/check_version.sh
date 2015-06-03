#!/bin/bash

## Check the contents of VERSION with the remote HEAD, and recommend 
##   updating if different.

localversion=`cat ~/.dotfiles/VERSION`
remoteversion=`cd ~/.dotfiles/ && git rev-parse origin/master`

if [ $localversion != $remoteversion ]; then
	echo -e "\x1B[33mYour dot.dotfiles versions are different.\x1B[0m"
fi
