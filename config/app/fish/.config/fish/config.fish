# vim: ts=4 sts=4 sw=4
# Atalariq's Fish Config

# ── Shell ──────────────────────────────────────────────
set -U fish_greeting

# ── Interactive only ───────────────────────────────────
if status is-interactive
    if command -q starship
        starship init fish | source
    end

    if command -q atuin
        atuin init fish | source
    end

    if command -q zoxide
        zoxide init fish | source
        alias zz "z -"
        alias .. "z .."
        alias ... "z ../.."
        alias .... "z ../../.."
        abbr -a zl "z ~/Downloads/"
        abbr -a zd "z ~/Documents/"
        abbr -a zc "z ~/Repos/dotfiles/"
    end

    if command -q mise
        mise activate fish | source
    end

    if not set -q SSH_AUTH_SOCK
        eval (ssh-agent -c) > /dev/null
    end

    bind \en down-or-search
    bind \ep up-or-search
end

# wana TTY palette — apply on Linux virtual console login
if test "$TERM" = linux; and test -r "$HOME/.local/script/wana-tty-current.sh"
    sh "$HOME/.local/script/wana-tty-current.sh"
end
