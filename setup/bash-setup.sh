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
  util::print "\nUsage: setup/bash-setup.sh \n"
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
  util::print "         ${green}Elevating privileges now...${noColour}\n\n"
  if sudo -v > /dev/null ; then 
    sudoer="YES"
  else 
    sudoer="NO"
  fi
  util::debug "sudo access? ${sudoer}"

  ## macOS specific tests.
  if [ "${os}" == "macos" ] ; then 
    ## Install the macOS command line tools if necessary
    util::debug "Testing for command line tools."
    if ! /usr/bin/xcode-select -p > /dev/null ; then 
      util::print "${blue}[ACTION]${noColour} The Xcode command line tools are not installed, and the script requires them."
      if util::confirm "${yellow}Proceed with install?${noColour} " ; then 
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
      util::warn "Homebrew isn't installed.\n"
      if util::confirm "${yellow}Proceed with install?${noColour} " ; then 
        util::print "${blue}[ACTION] Installing Homebrew${noColour}...\n"
        mkdir "${brew_repo}"
        /usr/bin/git clone git@github.com:Homebrew/brew.git "${brew_repo}"
        eval "$("${brew_bin}"/brew shellenv)"
        "${brew_bin}"/brew update --force --quiet
        /bin/chmod -R go-w "${brew_bin}/share/zsh"
      else
        util::error "Cannot proceed without Homebrew. Bailing out!"
        exit 99
      fi
    fi
    
    ## Install coreutils
    util::debug "Testing for coreutils"
    if ! "${brew_bin}"/brew list | /usr/bin/grep "coreutils" &>/dev/null ; then 
      util::warn "Coreutils isn't installed."
      if util::confirm "${yellow}Proceed with installation?${noColour} " ; then 
        util::print "${blue}[ACTION] Installing coreutils via brew${noColour}..."
        if ! brew_install coreutils ; then 
          util::error "Homebrew coreutils installation failed. Bailing out!"
          exit 74
        fi
      else 
        util::error "Cannot proceed without coreutils. Bailing out!"
        exit 88
      fi
    fi

    ## Architecture specific path for readlink.
    readlink="${brew_bin}/greadlink"
  fi

  if [ "${os}" == "linux" ] ; then 
    if type readlink >/dev/null 2>&1 ; then 
      readlink="$(command -v readlink)"
    else 
      util::error "${orange}readlink${noColour} is not installed, or not on your path. \\nThere is something odd with your setup. Please check it, and try again."
    fi
  fi

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
      util::print "${blue}[ACTION]${noColour} Creating ${dotfiles_prefix} symlink in ${HOME}.\n"
      if ! ln -s "${PWD}" "${dotfiles_prefix}" ; then
        util::error "The symlink ${dotfiles_prefix} » ${PWD} could not be created. Bailing out!"
        exit 1
      fi
    fi
  fi
}

function brew_install() {
  util::print "  ${green}[BREW]${noColour} Installing ${1}.\n"
  util::debug "Attempting ${brew_bin}/brew install ${1}\n"
  "${brew_bin}"/brew install "${1}"
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
  sleep 1
}

function create_local_config_file () {
  configfile="${1}"
  util::print "${blue}[ACTION]${noColour} Checking for existing .${configfile}_local.\n"
  if [ -f "${HOME}/.${configfile}_local" ] ; then 
    if ! util::confirm "${orange}[QUERY]${noColour} ${HOME}/.${configfile}_local exists. Continue to use it?" ; then 
      util::print "${blue}[ACTION]${noColour} Preserving existing .${configfile}_local as ${green}.${configfile}_local.bak-${ds}${noColour}\n"
      mv "${HOME}/.${configfile}_local" "${HOME}/.${configfile}_local.bak-${ds}"
    else 
      util::print "${blue}[ACTION]${noColour} Retaining existing .${configfile}_local.\n"
    fi
  else 
    util::print "${blue}[ACTION]${noColour} Creating empty .${configfile}_local.\n"
    touch "${HOME}/.${configfile}_local"
  fi
  sleep 1
}

function download_git_completion () {
  gcfile="${1}"
  util::print "${blue}[ACTION]${noColour} Checking for existing ${gcfile}.\n"
  if [ -d "${HOME}/bin" ] ; then 
    gcfile_path="${HOME}/bin/${gcfile}"
  else 
    gcfile_path="${HOME}/.${gcfile}"
  fi
  if [ -f "${gcfile_path}" ] ; then 
    if ! util::confirm "${orange}[QUERY]${noColour} ${gcfile_path} exists. Continue to use it?" ; then 
      util::print "${blue}[ACTION]${noColour} Preserving existing .${gcfile} as ${green}.${gcfile}.bak-${ds}${noColour}\n"
      mv "${gcfile_path}" "${gcfile_path}.bak-${ds}"
    else 
      util::print "${blue}[ACTION]${noColour} Retaining existing ${gcfile_path}.\n"
    fi
  else
    util::print "${blue}[ACTION]${noColour} Installing ${gcfile_path}\n"
    if ! curl -s "https://raw.githubusercontent.com/git/git/master/contrib/completion/${gcfile}" -o "${gcfile_path}" ; then 
      util::warn "${gcfile} did not download correctly. Please manually confirm this file was installed."
    else 
      util::debug "The download of ${gcfile} completed successfully."
      util::print "${blue}[ACTION]${noColour} adding ${gcfile_path} to ${HOME}/.bash_profile_local.\n"
      eval echo "source \"${gcfile_path}\" >> ${HOME}/.bash_profile_local"
    fi
  fi
  sleep 1
}

util::debug "Script Environment: "
util::debug "        Architecture: ${architecture}"
util::debug "        brew_prefix:  ${brew_prefix}"
util::debug "        brew_repo:    ${brew_repo}"
util::debug "        brew_bin:     ${brew_bin}"

util::debug "Software Versions to install:"
util::debug "        bash completion: ${bash_completion_version}"

util::print "Setting up the ${red}D${orange}O${yellow}T${green}F${cyan}I${blue}L${magenta}E${white}S${noColour}!\n"

util::confirm_requirements

## -=-=-= MAIN SCRIPT =-=-=- ##

## Create $HOME/bin directory.
util::debug "Checking for ${HOME}/bin directory."
if ! [ -d "${HOME}/bin" ] ; then 
  util::warn "${green}${HOME}/bin${noColour} does not exist. It is not required, but is recommended."
  if util::confirm "Create it? " ; then 
    true 
    util::print "${blue}[ACTION]${noColour} Create ${green}${HOME}/bin${noColour}.\n"
    mkdir "${HOME}/bin"
  else 
    util::print "${orange}[INFO]${noColour} Skipping creation of ${green}${HOME}/bin${noColour}."
  fi 
fi

## Install bash completion
if [ "$(uname)" = "Darwin" ]; then
  util::debug "Checking for bash-completion@2 installation"
  if ! [ -f "${brew_prefix}"/etc/profile.d/bash_completion.sh ] ; then
    util::print "${orange}[INFO]${noColour} bash-completion v2 is not required, but is recommended."
    if util::confirm "${yellow}Would you like to install it?${noColour} " ; then 
      if [ -f "${brew_bin}"/brew ]; then
        util::print "Using 'brew' to install bash-completion@2."
        brew_install "bash-completion@2"
      else
        if [ "${sudoer}" ] ; then 
          util::print "${orange}[TODO]${noColour} Install bash-completion manually.\n"
        else 
          util::warn "Cannot install bash-completion@2. Please install manually."
        fi
      fi
    else
      util::print "${orange}[INFO]${noColour} Skipping installation of bash-completion.\n"
    fi
  fi
fi

## Create local config files if needed.
create_local_config_file "bash_profile"
create_local_config_file "gitconfig"
create_local_config_file "bashrc"

## Install dot files proper.
install_config "bash_profile"
install_config "bashrc"
install_config "bash_logout"
install_config "gitconfig"
install_config "gitignore"
install_config "inputrc"
install_config "vimrc"
install_config "vim"

## Install git-completion and git-prompt
download_git_completion "git-completion.bash"
download_git_completion "git-prompt.sh"

## Install some useful software
if [ "${os}" == "macos" ] ; then 
  if util::confirm "${orange}[QUERY]${noColour} Install some useful software? " ; then 
    brew_install "bash"                 # bash higher than v3
    brew_install "shellcheck"           # for checking shell scripts
    brew_install "rectangle"            # macOS window manager
    brew_install "syntax-highlight"     # code syntax highlighting in quicklook
    brew_install "qlmarkdown"           # markdown rendering in quicklook
    brew_install "spotify"              # streaming music
    brew_install "discord"              # discord chat
    brew_install "iterm"                # better terminal program
  fi
fi

util::print "${bold}COMPLETE!${noColour}\n"
util::print "There's probably a lot more to properly do here, but we'll continue with it later.\n"
