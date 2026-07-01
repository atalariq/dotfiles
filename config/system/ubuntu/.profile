#!/bin/sh
# vim: ft=sh ts=4 sw=4:
# shellcheck disable=SC2155,SC1091
# Portable POSIX login profile — Ubuntu/Debian. Degrades gracefully when
# nvim/bat/fish are not installed (fresh VPS).

# ========================================== Editor / pager (with fallbacks)

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

if command -v tput >/dev/null 2>&1; then
    export SUDO_PROMPT="$(tput bold setaf 1)(sudo)$(tput sgr0) $(tput setaf 6)password for$(tput sgr0) $(tput bold setaf 3)%p$(tput sgr0): "
fi

# ========================================== PATH

case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
esac

# Load encrypted secrets (shell-agnostic; no-op if loader absent)
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

# wana TTY palette — apply on Linux virtual console login
if [ "$TERM" = "linux" ] && [ -r "$HOME/.local/script/wana-tty-current.sh" ]; then
    . "$HOME/.local/script/wana-tty-current.sh"
fi

# wana: apply active variant to bat + fzf (no-op if wana/bat/fzf absent)
_wana_variant=dark
[ -r "$HOME/.cache/wana/variant" ] && _wana_variant="$(cat "$HOME/.cache/wana/variant")"
export BAT_THEME="wana-$_wana_variant"
export FZF_DEFAULT_OPTS="--height=40% --layout=reverse --border"
_wana_fzf="$HOME/.config/fzf/wana-$_wana_variant.opts"
[ -r "$_wana_fzf" ] && export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS $(cat "$_wana_fzf")"
