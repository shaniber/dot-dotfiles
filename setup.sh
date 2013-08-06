#!/bin/bash

###
# Simple set up script to link dotfiles in a new environment.

ln -s ~/.dotfiles/dot.bash_logout		~/.bash_logout
ln -s ~/.dotfiles/dot.bash_profile		~/.bash_profile
ln -s ~/.dotfiles/dot.bashrc			~/.bashrc
ln -s ~/.dotfiles/dot.git-completion	~/.git-completion
ln -s ~/.dotfiles/dot.gitconfig			~/.gitconfig
ln -s ~/.dotfiles/dot.git-prompt		~/.git-prompt
ln -s ~/.dotfiles/dot.vimrc				~/.vimrc
