#!/bin/sh
# vim: ft=sh ts=4 sw=4:
# shellcheck disable=SC2155,SC1091
# Portable POSIX login profile — macOS. Editor/pager with fallbacks + secrets.

if command -v nvim >/dev/null 2>&1; then
    export EDITOR="nvim"
    export MANPAGER="nvim +Man!"
elif command -v vim >/dev/null 2>&1; then
    export EDITOR="vim"
else
    export EDITOR="vi"
fi
export VISUAL="$EDITOR"
export SUDO_EDITOR="$EDITOR"

if command -v bat >/dev/null 2>&1; then
    export PAGER="bat --paging=always"
else
    export PAGER="less"
fi

# Load encrypted secrets (shell-agnostic; no-op if loader absent)
[ -r "$HOME/.local/script/secrets-load" ] && . "$HOME/.local/script/secrets-load"

# wana: apply active variant to bat + fzf (no-op if wana/bat/fzf absent)
_wana_variant=dark
[ -r "$HOME/.cache/wana/variant" ] && _wana_variant="$(cat "$HOME/.cache/wana/variant")"
export BAT_THEME="wana-$_wana_variant"
export FZF_DEFAULT_OPTS="--height=40% --layout=reverse --border"
_wana_fzf="$HOME/.config/fzf/wana-$_wana_variant.opts"
[ -r "$_wana_fzf" ] && export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS $(cat "$_wana_fzf")"
