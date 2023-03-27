# ~/.bash_logout: executed by bash(1) when login shell exits.

# shellcheck shell=bash

# when leaving the console clear the screen to increase privacy
if [ "${SHLVL}" = 1 ] && [ "${os}" == "linux" ]; then
    [ -x /usr/bin/clear_console ] && /usr/bin/clear_console -q
fi

