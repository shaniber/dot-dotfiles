#!/bin/bash

## Compare the local and remote revisions to make sure that local
## is up-to-date.

`cd ~/.dotfiles && git fetch >> /dev/null 2>&1`

localversion=`cd ~/.dotfiles && git rev-parse HEAD`
remoteversion=`cd ~/.dotfiles/ && git rev-parse origin/master`

if [ $localversion != $remoteversion ]; then
	echo -e "\x1B[33mYour dot.dotfiles version is out of date.\x1B[0m"
fi
