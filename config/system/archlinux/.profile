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

# wana TTY palette — apply on Linux virtual console login
if [ "$TERM" = "linux" ] && [ -r "$HOME/.local/script/wana-tty-current.sh" ]; then
    . "$HOME/.local/script/wana-tty-current.sh"
fi

# wana: apply active variant to bat + fzf (login/bash)
_wana_variant=dark
[ -r "$HOME/.cache/wana/variant" ] && _wana_variant="$(cat "$HOME/.cache/wana/variant")"
export BAT_THEME="wana-$_wana_variant"
export FZF_DEFAULT_OPTS="--height=40% --layout=reverse --border"
_wana_fzf="$HOME/.config/fzf/wana-$_wana_variant.opts"
[ -r "$_wana_fzf" ] && export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS $(cat "$_wana_fzf")"
