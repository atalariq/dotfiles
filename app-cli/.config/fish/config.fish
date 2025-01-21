# Locale
set -gx LANG en_US.UTF-8
set -gx LC_ALL en_US.UTF-8

# Exports
set -gx EDITOR (which nvim)
set -gx VISUAL $EDITOR
set -gx SUDO_EDITOR $EDITOR

# Fish
set -U fish_greeting

# Commands to run in interactive sessions can go here
if status is-interactive
    # Use starship as Shell Prompt (https://starship.rs/)
    starship init fish | source

    # Start zoxide (https://github.com/ajeetdsouza/zoxide)
    zoxide init fish | source

    # Bindings
    bind \en down-or-search
    bind \ep up-or-search
end


# Created by `pipx` on 2024-10-11 12:57:14
set PATH $PATH /home/atalariq/.local/bin
