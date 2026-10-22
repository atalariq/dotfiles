# vim: ts=4 sts=4 sw=4
# Atalariq's Fish Config

# ── Shell ──────────────────────────────────────────────
set -g fish_greeting

# ── Interactive only ───────────────────────────────────
if status is-interactive
    if command -q starship
        starship init fish | source
    end

    if command -q atuin
        atuin init fish --disable-up-arrow | source
    end

    if command -q zoxide
        zoxide init fish | source
        alias zz "z -"
        alias .. "z .."
        alias ... "z ../.."
        alias .... "z ../../.."
        abbr -a zl "z ~/Downloads/"
        abbr -a zd "z ~/Documents/"

    end

    bind \en down-or-search
    bind \ep up-or-search
end

# Machine preferences load after the shared configuration.
if test -f $__fish_config_dir/config.local.fish
    source $__fish_config_dir/config.local.fish
end
