# dot-dotfiles

A collection of config files, custom to me. You probably shouldn't use them. In fact, at this point, I am specifically waiving any responsibility for these, and offering no warranties, explicit or implied. If you use these, changes will be made to your system and account that can break a lot of things for you.  

**USE THESE AT YOUR OWN RISK**, and don't come to me if something gets f\*\*\*ed up. I've warned you, and unless you pay me, I'm probaby just going to tell you "that sucks and I'm sorry, but you read the README where I said don't use these, right?"  

## Installation

**NOTE 1:** The installation script is extremely opinionated about what goes where. It will offer to install a lot of software, some of which it needs to complete its installations. It will offer to create empty local config file includes, or use existing ones. It will try to save any existing config files that exist with `.BAK-{DateStamp}` extensions, but doesn't make any promises that it will succeed. It doesn't clean up after itself if anything fails, but it will tell you what it's doing as it's doing it so that you can suss out what's been changed if something goes awry.  

**NOTE 2:** This installation script will try to add `{BREW_BIN_PATH}/bash` as your default shell if you let it. If it changes it, but then you remove that shell for some reason, you're going to have a really bad time until you change your shell through the _Users & Groups_ preferences pane » your user » right click » advanced. (Or something like that, I'm not going to look it up, it's somewhere around there.)  

**NOTE 3:** The installation script expects to be run from the root of this repository. If you run it directly in the setup directory, it'll probably behave unexpectedly.  

Have you read all of that, and you _still_ want to use these? Alright, go hard.  

1. Change into the directory that you've pulled this repository from.
2. Run the script `setup/bash-setup.sh`. 

## Usage
First, the dotfiles themselves should never be modified. The represent the platonic ideal of a dotfile.  Instead, you should only modify the .\*\_local file that corresponds to the file you would normally modify. This keeps your local modifications local, and keeps the multi-system generic configurations pristine. 

Next, there are several configuration files that don't support including other files, that might be modified as you use the programs they correspond to. If this is the case, consider if these are local changes or generic changes, and commit them back to your copy of the repository as appropriate. 

## Notes
There's a lot of other dotfiles repos out there. I've borrowed ideas from a lot of them. Here's a few that I've liked over the years.

- https://github.com/skx/dotfiles/
- https://github.com/unrolled/dotfiles
- https://github.com/mathiasbynens/dotfiles
