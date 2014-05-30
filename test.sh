#!/bin/bash

###
# Simple set up script to link dotfiles in a new environment.

# bash
if [ ! -e ~/.bash_ ] ; then echo ".bash_logout does not exist" ; fi
if [ -e ~/.bash_ ] ; then echo ".bash_logout DOES exist" ; fi

#ln -s ~/.dotfiles/dot.bash_profile		~/.bash_profile
#ln -s ~/.dotfiles/dot.bashrc			~/.bashrc
#
## git
#ln -s ~/.dotfiles/dot.git-completion	~/.git-completion
#ln -s ~/.dotfiles/dot.gitconfig			~/.gitconfig
#ln -s ~/.dotfiles/dot.git-prompt		~/.git-prompt
#ln -s ~/.dotfiles/dot.gitignore			~/.gitignore 
#
## vim
#ln -s ~/.dotfiles/dot.vimrc				~/.vimrc
