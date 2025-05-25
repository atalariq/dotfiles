#!/bin/sh
# vim: ft=sh ts=4 sw=4:
# shellcheck disable=SC2155,SC1091

# ========================================== Directory

export CARGO_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/cargo"
export GOPATH="${XDG_DATA_HOME:-$HOME/.local/share}/go"
export GOBIN="$GOPATH/bin"

export GNUPGHOME="${XDG_DATA_HOME:-$HOME/.local/share}/gnupg"
export HISTFILE="${XDG_DATA_HOME:-$HOME/.local/share}/history"
export TERMINFO="${XDG_DATA_HOME:-$HOME/.local/share}/terminfo"
export WWW_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/w3m"
export WGETRC="${XDG_CONFIG_HOME:-$HOME/.config}/wget/wgetrc"

export EDITOR="nvim"
export VISUAL=$EDITOR
export SUDO_EDITOR=$EDITOR
# export SUDO_PROMPT="$(tput bold setab 1 setaf 0)(sudo)$(tput sgr0) $(tput setaf 6)password for$(tput sgr0) $(tput setaf 3)%p$(tput sgr0): "

# ================================ PATH {{{
TO_PATH() {
	if [ -d "$1" ]; then
		if ! printf "%s" "$PATH" | grep -q "$1"; then
			export PATH="$PATH:$1"
		fi
	fi
}

TO_PATH "$HOME/bin"
TO_PATH "$HOME/.local/bin"
TO_PATH "$HOME/.local/script"


# }}}

# ============================= Others

export CHROME_PATH=/usr/bin/google-chrome-stable
export CHROME_EXECUTABLE=/usr/bin/google-chrome-stable

