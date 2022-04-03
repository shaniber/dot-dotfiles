#!/bin/bash

###
# Simple set up script to link dotfiles in a new environment.

## Sugar.
bold=$(tput bold)
reverse=$(tput rev)
red=$(tput setaf 1)
orange=$(tput setaf 202)
yellow=$(tput setaf 3)
green=$(tput setaf 2)
cyan=$(tput setaf 6)
blue=$(tput setaf 4)
magenta=$(tput setaf 5)
white=$(tput setaf 7)
noColour=$(tput sgr 0)
readonly bold reverse red orange yellow green cyan blue magenta white noColour

## Set to 1 to enable debugging
DEBUG=${DEBUG-0}

## Useful globals
dotfiles_prefix="${HOME}/.dotfiles"

## Determine our architecture.
architecture=$(/usr/sbin/sysctl -n machdep.cpu.brand_string)

## Setting up our homebrew configuration
if [[ "$architecture" =~ "Apple" ]] ; then
  brew_prefix="/opt/homebrew"
  brew_repo="${brew_prefix}"
  brew_bin="${brew_prefix}/bin"
else 
  brew_prefix="/usr/local/"
  brew_repo="${brew_prefix}/Homebrew"
  brew_bin="${brew_prefix}/bin"
fi

# Software to install
bash_completion_version="2.11"

# Current datestamp
ds=$(date +%Y%m%d%H%M%S)

## Debugging.
function util::debug() {
  if [ "$DEBUG" == 1 ] ; then
    printf '%s[DEBUG]%b %b \n' "${blue}" "${noColour}" "${1}"
  fi
}

## Generic printing.
function util::print() {
  if [ ! "$SILENT" == 1 ] ; then
    printf "%b" "${1}"
  fi
}

## Error reporting.
function util::error() {
  util::debug "An error has occurred."
  printf "\n%b%b[ERROR]%b %s\n\n" "${red}" "${reverse}" "${noColour}" "${1}" >&2 
}

## Warning reporting.
function util::warn() {
  util::debug "A warning has occurred."
  printf "\n%b%b[WARN]%b  %s\n\n" "${yellow}" "${reverse}" "${noColour}" "$1">&2
}

## Pause for keypress.
function util::pause() {
  util::print "${green}Press any key to continue...${noColour}\n"
  read -n 1 -s -r
}

## Confirm (with prompt).
function util::confirm() {
  local prompt input
  if [ -n "$1" ] ; then
    prompt="$1"
  else 
    prompt="Confirm"
  fi
  prompt="${prompt} [Y/n]: "

  while true ; do
    read -r -p "${prompt}" input
    case $input in
      # Y/y or enter is yes. 
      ""|[Yy]* )
        return 0
        ;;
      # N/n is no
      [Nn]* ) 
        return 1
        ;;
      # Anything else is ignored.
      * ) 
        ;;
    esac
  done
}

## Usage.
function util::usage() {
  util::print "\nUsage: setup/bash-setup.sh \n\n"
}

## Check for script tool requirements.
function util::confirm_requirements() {
  util::debug "Checking script requirements."

  ## Ensure that we're being executed in the required manner. 
  if [ "$0" != "setup/bash-setup.sh" ] ; then 
    util::debug "This script was executed as [$0]."
    util::error "Please run this script from the root of this repository."
    util::usage
    exit 1
  fi

  ## Check our operating system.
  util::debug "Testing operating system."
  if [ "$(uname)" == "Darwin" ] ; then
    os="macos"
  elif [ "$(uname)" == "Linux" ] ; then 
    os="linux"
  else 
    util::error "I don't know what operating system you're trying to install on. Bailing out!"
    exit 9
  fi

  ## Test for sudo access.
  util::debug "Testing for sudo access."
  util::print "${blue}[ACTION] ${yellow}Elevated privileges are recommended.${noColour}\n"
  util::print "         If you do not have sudo access, there may be some actions that you cannot perform.\n"
  util::print "         These are not required for setup completion, just useful.\n"
  util::print "         You may be prompted for your password in the next step.\n\n"
  util::print "         ${green}Elevating privileges now...${noColour}\n"
  if sudo -v > /dev/null ; then 
    sudoer="YES"
  else 
    sudoer="NO"
  fi
  util::debug "sudo access? ${sudoer}"

  ## macOS specific tests.
  if [ "$os" == "macos" ] ; then 
    ## Install the macOS command line tools if necessary
    util::debug "Testing for command line tools."
    if ! /usr/bin/xcode-select -p > /dev/null ; then 
      util::print "${blue}[ACTION]${noColour} The Xcode command line tools are not installed, and the script requires them."
      if util::confirm "${yellow}Proceed with install?${noColour}" ; then 
        # TODO: install xcode command line tools
        util::print "${green}Installing command line tools${noColour}..."
        touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress;
        PROD=$(/usr/sbin/softwareupdate -l |
          /usr/bin/grep "\*.*Command Line" |
          /usr/bin/sort -r | 
          /usr/bin/head -n 1 | 
          /usr/bin/awk -F": " '{print $2}' |
          /usr/bin/tr -d '\n')
        util::debug "Installing ${yellow}${PROD}${noColour}."
        softwareupdate -i "$PROD" -v;
      else 
        # Can't proceed without command line tools, exit.
        util::error "Cannot proceed without command line tools. Bailing out!"
        exit 23
      fi
    else 
      util::debug "Xcode command line tools are installed."
    fi

    ## Install homebrew if necessary.
    util::debug "Testing for Homebrew."
    if ! "${brew_bin}"/brew --version > /dev/null ; then
      if util::confirm "${blue}[ACTION]${noColour} Homebrew isn't installed. Shall I attempt to install it?" ; then 
        # TODO: install homebrew
        util::print "${green}Installing Homebrew${noColour}...\n"
        mkdir "${brew_repo}"
        /usr/bin/git clone git@github.com:Homebrew/brew.git "${brew_repo}"
        eval "$("${brew_bin}"/brew shellenv)"
        "${brew_bin}"/brew update --force --quiet
        /bin/chmod -R go-w "${brew_bin}/share/zsh"
      else
        util::warn "This may result in problems during the setup, and with execution later on."
        if util::confirm "        ${yellow}Are you sure?${noColour}" ; then
          util::print "\n${green}Continuing installation without Homebrew${noColour}...\n"
        else 
          util::print "\n${magenta}You are clearly confused. Exiting until you sort yourself out.${noColour}\n\n"
          exit 0
        fi
      fi
    fi
    
    ## Install coreutils
    util::debug "Installing coreutils"
    if ! "${brew_bin}"/brew list | /usr/bin/grep -q "coreutils" &>/dev/null ; then 
      if ! "${brew_bin}"/brew install coreutils ; then 
        util::error "Homebrew coreutils installation failed. Bailing out!"
        exit 74
      fi
    fi

    ## Architecture specific path for readlink.
    readlink="${brew_bin}/greadlink"
  fi

  if [ "$os" == "linux" ] ; then 
    if type readlink >/dev/null 2>&1 ; then 
      readlink="$(command -v readlink)"
    else 
      util::error "${orange}readlink${noColour} is not installed, or not on your path. \\nThere is something odd with your setup. Please check it, and try again."
    fi
  fi
} 

function install_config () {
  dotfile="${1}"
  util::print "${blue}[ACTION]${noColour} Installing .${dotfile}.\n"
  if [ -f "${HOME}/.${dotfile}" ] && [ ! -L "${HOME}/.${dotfile}" ]; then
    util::print "         (Preserving existing at .${dotfile}.bak-${ds}\n"
    mv "${HOME}/.${dotfile}" "${HOME}/.${dotfile}.bak-${ds}"
  else 
    if ${readlink} "${HOME}/.${dotfile}" | /usr/bin/grep -q "${dotfiles_prefix}/dot.${dotfile}" ; then
      util::warn ".${dotfile} exists and point to the expected installation directory. Skipping..."
    else 
      ln -s "${dotfiles_prefix}/dot.${dotfile}" "${HOME}/.${dotfile}"
    fi
  fi
}

util::debug "Script Environment: "
util::debug "        Architecture: ${architecture}"
util::debug "        brew_prefix:  ${brew_prefix}"
util::debug "        brew_repo:    ${brew_repo}"
util::debug "        brew_bin:     ${brew_bin}"

util::debug "Software Versions to install:"
util::debug "        bash completion: ${bash_completion_version}"

util::confirm_requirements

util::print "Setting up the ${red}D${orange}O${yellow}T${green}F${cyan}I${blue}L${magenta}E${white}S${noColour}!\n"

## Make sure the dot files are available in an expected spot.
util::debug "Checking if ${dotfiles_prefix} exists and is in an expected state."
if [ "${PWD}" != "${dotfiles_prefix}" ] ; then
  # check to make sure the ${HOME}/.dotfiles path doesn't already exist.
  if [ -L "${dotfiles_prefix}" ] || [ -d "${dotfiles_prefix}" ] ; then
    # Check if the README exists and if it is our readme file.
    if [ -f "${dotfiles_prefix}/README.md" ] ; then
      if ! /usr/bin/grep -Fxq "# dot.dotfiles" "${dotfiles_prefix}/README.md" ; then
        util::error "${dotfiles_prefix} exists, but has unexpected content. Bailing out!"
        exit 2
      else 
        util::debug "Looks like ${dotfiles_prefix} is in good shape. Let's go!"
      fi
    else
      util::error "${dotfiles_prefix} exists, but is in an unexpected state. Bailing out!"
      exit 3
    fi
  else 
    util::print "No ${dotfiles_prefix} symlink exists. Creating..."
    if ! ln -s "${PWD}" "${dotfiles_prefix}" ; then
      util::error "The symlink ${dotfiles_prefix} » ${PWD} could not be created. Bailing out!"
      exit 1
    fi
  fi
fi

exit 99

## Install bash completion
if [ "$(uname)" = "Darwin" ]; then
  util::debug "Checking for bash-completion@2 installation"
  if ! [ -f "${brew_prefix}"/etc/profile.d/bash_completion.sh ] ; then
    if [ -f "${brew_bin}"/brew ]; then
      util::print "Using 'brew' to install bash-completion@2."
      "${brew_bin}"/brew install bash-completion@2
    else
      if [ "${sudoer}" ] ; then 
        util::print "${orange}[TODO]${noColour} Install bash-completion manually.\n"
      else 
        util::warn "Cannot install bash-completion@2. Please install manually."
      fi
    fi
  fi
fi

## -=-=-= MAIN SCRIPT =-=-=- ##

## .bash_profile_local
util::print "${blue}[ACTION]${noColour} Checking for exising .bash_profile_local.\n"
if [ -f "${HOME}/.bash_profile_local" ] ; then 
  if ! util::confirm "${HOME}/.bash_profile_local exists. Continue to use it?" ; then 
    util::print "${blue}[ACTION]${noColour} Preserving exising .bash_profile_local as  .bash_profile_local.bak-${ds}\n"
    mv "${HOME}/.bash_profile_local" "${HOME}/.bash_profile_local.bak-${ds}"
  else 
    util::print "${blue}[ACTION]${noColour} Retaining exising .bash_profile_local\n"
  fi
else
  touch "${HOME}/.bash_profile_local"
fi

## Install dot files proper.
install_config "bash_profile"
install_config "bashrc"
install_config "bash_logout"
install_config "git-config"
install_config "gitignore"
install_config "inputrc"
install_config "vimrc"
install_config "vim"

## Install git-completion
util::print "${blue}[ACTION]${noColour} Installing git-completion.bash\n"
if [ -f "${HOME}/.git-completion.bash" ] ; then
  mv "${HOME}"/.git-completion.bash "${HOME}/.git-completion.bash.orig-${ds}"
fi
curl "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash" -o "${HOME}/.git-completion.bash"
### TODO: Check if .bash_profile_local exists, and concatenate the git-completion source to it. 

## Install git-prompt
util::print "${blue}[ACTION}${noColour} Installing git-prompt.bash\n"
if [ -f "${HOME}/.git-prompt.sh" ] ; then 
  mv "${HOME}.git-completion.sh" "${HOME}/.git-prompt.sh.orig-${ds}"
fi
curl "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh" -o "${HOME}/.git-prompt.bash"
### TODO: Check if .bash_profile_local exists, and concatenate the git-completion source to it. 

util::print "${bold}COMPLETE!${noColour}\n"
util::print "There's probably a lot more to properly do here, but we'll continue with it later.\n"