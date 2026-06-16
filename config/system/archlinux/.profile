#!/bin/sh
# vim: ft=sh ts=4 sw=4:
# shellcheck disable=SC2155,SC1091

# ========================================== Directory

export EDITOR="nvim"
export VISUAL=$EDITOR
export SUDO_EDITOR=$EDITOR
export SUDO_PROMPT="$(tput bold setaf 1)(sudo)$(tput sgr0) $(tput setaf 6)password for$(tput sgr0) $(tput bold setaf 3)%p$(tput sgr0): "

export PAGER="bat --paging=always"
export MANPAGER="nvim +Man!"

# Load encrypted secrets (shell-agnostic)
[ -r "$HOME/.local/script/secrets-load" ] && . "$HOME/.local/script/secrets-load"

# SSH auth socket fix
if [ -z "${SSH_AUTH_SOCK:-}" ]; then
    for sock in \
      "$XDG_RUNTIME_DIR/gcr/ssh" \
      "$XDG_RUNTIME_DIR/keyring/ssh"
    do
      if [ -S "$sock" ]; then
        export SSH_AUTH_SOCK="$sock"
        break
      fi
    done
  fi


# Added by Antigravity CLI installer
export PATH="/home/atalariq/.local/bin:$PATH"
