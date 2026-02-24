# vim: ts=4 sts=4 sw=4 :
# Atalariq's Fish Config

set -gx LANG en_US.UTF-8
set -gx LC_COLLATE C.UTF-8
set -gx LC_MESSAGES en_US.UTF-8
set -gx LC_MEASUREMENT en_GB.UTF-8
set -gx LC_PAPER en_GB.UTF-8

# Disable Greeting
set -U fish_greeting

# Commands to run in interactive sessions can go here
if status is-interactive
    # Use starship as Shell Prompt (https://starship.rs/)
    if command -q starship
        starship init fish | source
    end

    # Start zoxide (https://github.com/ajeetdsouza/zoxide)
    if command -q zoxide
        zoxide init fish | source
    end

    # fnm, blazing fast node version manager alternative
    # (https://github.com/Schniz/fnm)
    if command -q fnm
        fnm env --use-on-cd --shell fish | source
    end

    # Bindings
    bind \en down-or-search
    bind \ep up-or-search
end

# Created by `pipx` on 2024-10-11 12:57:14
set PATH $PATH /home/atalariq/.local/bin
