#!/bin/bash

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
  printf "  %b%b[WARN]%b %s\n" "${yellow}" "${reverse}" "${noColour}" "$1">&2
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

