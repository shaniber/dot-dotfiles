#!/usr/bin/perl -w

###
# Setup Script to link dotfiles in a new environment.
#
# Assumes presence of relatively modern perl in /usr/bin.
#

# Check for existing dotfiles.

# bash
unless ( -e "$ENV{HOME}/.bash_logout" ) { print ".bash_logout does not exist.\n"; }
unless ( -e "$ENV{HOME}/.bash_profile" ) { print ".bash_profile does not exist.\n"; }
unless ( -e "$ENV{HOME}/.bashrc" ) { print ".bashrc does not exist.\n"; }
#ln -s ~/.dotfiles/dot.bash_logout               ~/.bash_logout;
#ln -s ~/.dotfiles/dot.bash_profile              ~/.bash_profile;
#ln -s ~/.dotfiles/dot.bashrc                    ~/.bashrc;

# git
#ln -s ~/.dotfiles/dot.git-completion    ~/.git-completion
#ln -s ~/.dotfiles/dot.gitconfig                 ~/.gitconfig
#ln -s ~/.dotfiles/dot.git-prompt                ~/.git-prompt
#ln -s ~/.dotfiles/dot.gitignore                 ~/.gitignore

# vim
#ln -s ~/.dotfiles/dot.vimrc                             ~/.vimrc

