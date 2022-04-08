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

## Determine the user running this script.
current_user=$(stat -f %Su /dev/console)

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
brew_installed=0
bash_installed=0
bash_completion_installed=0

# Current datestamp
ds=$(date +%Y%m%d%H%M%S)

## Debugging.
function util::debug() {
  if [ "$DEBUG" == 1 ] ; then
    printf ' %s[DEBUG]%b %b \n' "${cyan}${reverse}" "${noColour}" "${1}"
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
  printf "  %b%b[WARN]%b  %s\n\n" "${yellow}" "${reverse}" "${noColour}" "$1">&2
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
    sudoer=1
  else 
    sudoer=0
  fi
  util::debug "sudo access? ${sudoer}"

  ## macOS specific tests.
  if [ "${os}" == "macos" ] ; then 
    ## Install the macOS command line tools if necessary
    util::debug "Testing for command line tools."
    if ! /usr/bin/xcode-select -p &>/dev/null ; then 
      util::print "${blue}[ACTION]${noColour} The Xcode command line tools are not installed, and the script requires them.\n"
      if util::confirm " ${orange}[QUERY]${noColour} Proceed with install?" ; then 
        util::print "${green}Installing command line tools${noColour}...\n"
        touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress;
        PROD=$(/usr/sbin/softwareupdate -l |
          /usr/bin/grep "\*.*Command Line" |
          /usr/bin/sort -r | 
          /usr/bin/head -n 1 | 
          /usr/bin/awk -F": " '{print $2}' |
          /usr/bin/tr -d '\n')
        util::debug "Installing ${yellow}${PROD}${noColour}."
        softwareupdate -i "$PROD" --verbose;
        rm /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress;
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
    if ! "${brew_bin}"/brew --version &>/dev/null ; then
      util::warn "Homebrew isn't installed."
      if util::confirm " ${orange}[QUERY]${noColour} Proceed with install?" ; then 
        util::print "${blue}[ACTION] Installing Homebrew${noColour}...\n"
        sudo mkdir "${brew_repo}"
        sudo chown -R "${current_user}" "${brew_repo}"
        /usr/bin/git clone https://github.com/Homebrew/brew.git "${brew_repo}"
        eval "$("${brew_bin}"/brew shellenv)"
        "${brew_bin}"/brew analytics off 
        "${brew_bin}"/brew update --force --quiet
        "${brew_bin}"/brew tap homebrew/cask
        "${brew_bin}"/brew tap homebrew/cask-versions
        /bin/chmod -R go-w "${brew_prefix}/share/zsh"
        brew_installed=1
      else
        util::error "Cannot proceed without Homebrew. Bailing out!"
        exit 99
      fi
    fi
    
    ## Install coreutils
    util::debug "Testing for coreutils"
    if ! "${brew_bin}"/brew info coreutils | /usr/bin/grep "Poured" &>/dev/null ; then 
      util::warn "Coreutils isn't installed."
      if util::confirm " ${orange}[QUERY]${noColour} Proceed with installation?" ; then 
        util::print "${blue}[ACTION] Installing coreutils via brew${noColour}...\n"
        if ! brew_install "coreutils" ; then 
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

function link_config_file () {
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
    if ! util::confirm " ${orange}[QUERY]${noColour} ${HOME}/.${configfile}_local exists. Continue to use it?" ; then 
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
    if ! util::confirm " ${orange}[QUERY]${noColour} ${gcfile_path} exists. Continue to use it?" ; then 
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
      printf "source %s\n" "${gcfile_path}" >> "${HOME}/.bash_profile_local"
    fi
  fi
  sleep 1
}

util::debug "Script Environment: "
util::debug "        Architecture: ${architecture}"
util::debug "        brew_prefix:  ${brew_prefix}"
util::debug "        brew_repo:    ${brew_repo}"
util::debug "        brew_bin:     ${brew_bin}"
util::debug "        current_user: ${current_user}"

util::print "Setting up your fancy-schmancy new \n\n"
util::print "       ${red}D${noColour} - ${orange}O${noColour} - ${yellow}T${noColour} - ${green}F${noColour} - ${cyan}I${noColour} - ${blue}L${noColour} - ${magenta}E${noColour} - ${white}S${noColour}\n"
util::print "       ${white}S - ${red}D${noColour} - ${orange}O${noColour} - ${yellow}T${noColour} - ${green}F${noColour} - ${cyan}I${noColour} - ${blue}L${noColour} - ${magenta}E${noColour}\n"
util::print "       ${magenta}E${noColour} - ${white}S - ${red}D${noColour} - ${orange}O${noColour} - ${yellow}T${noColour} - ${green}F${noColour} - ${cyan}I${noColour} - ${blue}L${noColour}\n"
util::print "       ${blue}L${noColour} - ${magenta}E${noColour} - ${white}S - ${red}D${noColour} - ${orange}O${noColour} - ${yellow}T${noColour} - ${green}F${noColour} - ${cyan}I${noColour}\n"
util::print "       ${cyan}I${noColour} - ${blue}L${noColour} - ${magenta}E${noColour} - ${white}S - ${red}D${noColour} - ${orange}O${noColour} - ${yellow}T${noColour} - ${green}F${noColour}\n"
util::print "       ${green}F${noColour} - ${cyan}I${noColour} - ${blue}L${noColour} - ${magenta}E${noColour} - ${white}S - ${red}D${noColour} - ${orange}O${noColour} - ${yellow}T${noColour}\n"
util::print "       ${yellow}T${noColour} - ${green}F${noColour} - ${cyan}I${noColour} - ${blue}L${noColour} - ${magenta}E${noColour} - ${white}S - ${red}D${noColour} - ${orange}O${noColour}\n"
util::print "       ${orange}O${noColour} - ${yellow}T${noColour} - ${green}F${noColour} - ${cyan}I${noColour} - ${blue}L${noColour} - ${magenta}E${noColour} - ${white}S${noColour} - ${red}D${noColour}\n\n"

util::print "(Yes, I was bored. Be thankful I'm not proficient with ${bold}${reverse}tput${noColour} yet).\n"

util::confirm_requirements

## -=-=-= MAIN SCRIPT =-=-=- ##

## Create local config files if needed.
create_local_config_file "bash_profile"
create_local_config_file "gitconfig"
create_local_config_file "bashrc"

## Create $HOME/bin directory.
util::debug "Checking for ${HOME}/bin directory."
if ! [ -d "${HOME}/bin" ] ; then 
  util::warn "${green}${HOME}/bin${noColour} does not exist. It is not required, but is recommended."
  if util::confirm " ${orange}[QUERY]${noColour} Create it?" ; then 
    true 
    util::print "${blue}[ACTION]${noColour} Create ${green}${HOME}/bin${noColour}.\n"
    mkdir "${HOME}/bin"
  else 
    util::print "  ${magenta}[INFO]${noColour} Skipping creation of ${green}${HOME}/bin${noColour}.\n"
  fi 
fi

## Install recommended but optional software
if [ "${os}" = "macos" ] ; then 
  ## Install bash 4+
  util::debug "Checking for bash installation."
  if ! ${brew_bin}/brew info bash | /usr/bin/grep Poured &>/dev/null ; then 
    util::print "  ${magenta}[INFO]${noColour} Bash >4 is not required, but is recommended.\n"
    if util::confirm " ${orange}[QUERY]${noColour} Would you like to install it?" ; then
      if [ ${brew_installed} ] ; then 
        util::print "${blue}[ACTION]${noColour} using 'brew' to install bash.\n"
        if ! brew_install "bash" ; then 
          util::error "bash failed to install, for some reason. Continuing..."
        else
          bash_installed="$(${brew_bin}/bash --version | sed -Ee 's/GNU bash, version ([0-9.]+).*/\1/;q')"
        fi
      else 
        if [ "${sudoer}" ] ; then 
          util::print "  ${green}${reverse}[TODO]${noColour} Install base manually.\n"
        else
          util::warn "Cannot install bash. Please install manually."
        fi
      fi
    else 
      util::print "  ${magenta}[INFO]${noColour} Skipping installation of bash.\n"
    fi
  fi

  # If bash installed successfully, add it to /etc/shells.
  util::debug "Checking if bash should be added to /etc/shells"
  if [ "$(echo "${bash_installed}" | awk -F '.' '{print $1}')" -gt 0 ] && ! /usr/bin/grep "${brew_bin}" /etc/shells ; then
    util::print "${blue}[ACTION]${noColour} Adding ${brew_bin}/bash to /etc/shells.\n"
    sudo sh -c "echo \"${brew_bin}/bash\" >> /etc/shells"
    if ! [ ${SHELL} = "${brew_bin}"/bash} ] ; then 
      util::print "  ${magenta}[INFO]${noColour} Changing your shell to ${brew_bin}/bash is not required, but is recommended.\n"
      if util::confirm " ${orange}[QUERY]${noColour} Change your shell to ${brew_bin}/bash?" ; then 
        chsh -s "${brew_bin}/bash"
      fi
    fi
  fi

  ## Install bash completion
  util::debug "Checking for bash-completion installation, for bash v${bash_installed}."
  if [ "$(echo "${bash_installed}" | awk -F '.' '{print $1}')" -gt 3 ] ; then
    # Bash 4+ installed, so install bash_completion@2
    if ! [ -f "${brew_prefix}"/etc/profile.d/bash_completion.sh ] ; then
      util::print "  ${magenta}[INFO]${noColour} bash-completion v2 is not required, but is recommended.\n"
      if util::confirm " ${orange}[QUERY]${noColour} Would you like to install it?" ; then 
        if [ ${brew_installed} ]; then
          util::print "${blue}[ACTION]${noColour} Using 'brew' to install bash-completion@2.\n"
          brew_install "bash-completion@2"
          bash_completion_installed=1
        else
          if [ "${sudoer}" ] ; then 
            util::print "  ${green}${reverse}[TODO]${noColour} Install bash-completion@2 manually.\n"
          else 
            util::warn "Cannot install bash-completion@2. Please install manually."
          fi
        fi
      else
        util::print "  ${magenta}[INFO]${noColour} Skipping installation of bash-completion@2.\n"
      fi
    else
      bash_completion_installed=1
    fi
  else
    # System Bash 3 is installed, so just install bash_completion
    if ! [ -f "${brew_prefix}"/etc/bash_completion ] ; then
      util::print "  ${magenta}[INFO]${noColour} bash-completion is not required, but is recommended.\n"
      if util::confirm " ${orange}[QUERY]${noColour} Would you like to install it?" ; then 
        if [ ${brew_installed} ]; then
          util::print "${blue}[ACTION]${noColour} Using 'brew' to install bash-completion.\n"
          brew_install "bash-completion"
          bash_completion_installed=1
        else
          if [ "${sudoer}" ] ; then 
            util::print "  ${magenta}[TODO]${noColour} Install bash-completion manually.\n"
          else 
            util::warn "Cannot install bash-completion. Please install manually."
          fi
        fi
      else
        util::print "  ${magenta}[INFO]${noColour} Skipping installation of bash-completion@2.\n"
      fi
    else
      bash_completion_installed=1
    fi
  fi
  
  ## Put bash_completion include in the bash_profile_local, since it's not required.
  if [ "${bash_completion_installed}" ] ; then 
    util::print "${blue}[ACTION]${noColour} adding bash_completion to ${HOME}/.bash_profile_local.\n"
    {
      printf "# Bash completion (which should have been installed during setup)\n"
      printf "if command -v brew &> /dev/null && [ -r \"\$(brew --prefix)/etc/profile.d/bash_completion.sh\" ] ; then\n"
      printf "  export BASH_COMPLETION_COMPAT_DIR=\"\$(brew --prefix)/etc/bash_completion.d\";\n"
      printf "  source \"\$(brew --prefix)/etc/profile.d/bash_completion.sh\";\n"
      printf "elif [ -f /etc/bash_completion ]; then\n"
      printf "  source /etc/bash_completion;\n"
      printf "fi;\n"
    } >> "${HOME}/.bash_profile_local"
  fi
fi

## Install dot files proper.
link_config_file "bash_profile"
link_config_file "bashrc"
link_config_file "bash_logout"
link_config_file "gitconfig"
link_config_file "gitignore"
link_config_file "inputrc"
link_config_file "vimrc"
link_config_file "vim"

## Install git-completion and git-prompt
download_git_completion "git-completion.bash"
download_git_completion "git-prompt.sh"

## Offer to install some useful software
if [ "${os}" == "macos" ] ; then 
  if util::confirm "${orange}[QUERY]${noColour} Install some useful software?" ; then 
    brew_install "shellcheck"           # for checking shell scripts
    brew_install "rectangle"            # macOS window manager
    brew_install "syntax-highlight"     # code syntax highlighting in quicklook
    brew_install "qlmarkdown"           # markdown rendering in quicklook
    brew_install "spotify"              # streaming music
    brew_install "discord"              # discord chat
    brew_install "iterm"                # better terminal program
    brew_install "pandoc"               # markup format conversion
    brew_install "vscodium"             # rebuild of Visual Studio Code w/o telemetry
  fi
fi

util::print "${bold}COMPLETE!${noColour}\n"
util::print "There's probably a lot more to properly do here, but we'll continue with it later.\n"
