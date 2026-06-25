# vim: ts=4 sts=4 sw=4 :
# Atalariq's Fish Config

# ── Locale ─────────────────────────────────────────────
set -gx LANG en_US.UTF-8
set -gx LC_COLLATE C.UTF-8
set -gx LC_MESSAGES en_US.UTF-8
set -gx LC_MEASUREMENT en_GB.UTF-8
set -gx LC_PAPER en_GB.UTF-8

# ── Shell ──────────────────────────────────────────────
set -U fish_greeting

# ── Editor / Pager ─────────────────────────────────────
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx PAGER less
set -gx LESS "-R -F -X"
set -gx MANPAGER "nvim +Man!"

# ── Common CLI behavior ────────────────────────────────
set -gx RIPGREP_CONFIG_PATH "$HOME/.config/ripgrep/ripgreprc"
# wana: apply active variant to bat + fzf
set -l _wana_variant dark
test -r "$HOME/.cache/wana/variant"; and set _wana_variant (cat "$HOME/.cache/wana/variant")
set -gx FZF_DEFAULT_OPTS "--height=40% --layout=reverse --border"
set -l _wana_fzf "$HOME/.config/fzf/wana-$_wana_variant.opts"
test -r "$_wana_fzf"; and set -gx FZF_DEFAULT_OPTS "$FZF_DEFAULT_OPTS "(cat "$_wana_fzf")
set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
set -gx FZF_CTRL_T_COMMAND  $FZF_DEFAULT_COMMAND
set -gx FZF_ALT_C_COMMAND   'fd --type d --hidden --follow --exclude .git'
set -gx BAT_THEME "wana-$_wana_variant"

# ── XDG paths ──────────────────────────────────────────
set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx XDG_CACHE_HOME "$HOME/.cache"
set -gx XDG_DATA_HOME "$HOME/.local/share"
set -gx XDG_STATE_HOME "$HOME/.local/state"

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

    # if command -q tirith
    #     tirith init --shell fish | source
    # end

    if command -q mise
        mise activate fish | source
    end

    if not set -q SSH_AUTH_SOCK
        eval (ssh-agent -c) > /dev/null
    end

    bind \en down-or-search
    bind \ep up-or-search
end


# Added by Antigravity CLI installer
set -gx PATH "/home/atalariq/.local/bin" $PATH

# wana TTY palette — apply on Linux virtual console login
if test "$TERM" = linux; and test -r "$HOME/.local/script/wana-tty-current.sh"
    sh "$HOME/.local/script/wana-tty-current.sh"
end
