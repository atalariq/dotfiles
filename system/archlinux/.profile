#!/bin/sh
# vim: ft=sh ts=4 sw=4:
# shellcheck disable=SC2155,SC1091

# ========================================== Directory

export CARGO_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/cargo"
export GOPATH="${XDG_DATA_HOME:-$HOME/.local/share}/go"
export GOBIN="$GOPATH/bin"

export GNUPGHOME="${XDG_DATA_HOME:-$HOME/.local/share}/gnupg"
export HISTFILE="${XDG_DATA_HOME:-$HOME/.local/share}/history"

export EDITOR="nvim"
export VISUAL=$EDITOR
export SUDO_EDITOR=$EDITOR
export SUDO_PROMPT="$(tput bold setaf 1)(sudo)$(tput sgr0) $(tput setaf 6)password for$(tput sgr0) $(tput bold setaf 3)%p$(tput sgr0): "

export LESS='-RQS'
# export MANPAGER="less -R"
export MANPAGER="nvim +Man!"

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
TO_PATH "$HOME/.local/share/bob/nvim-bin"
TO_PATH "$GOBIN"
TO_PATH "$CARGO_HOME/bin"
# }}}
