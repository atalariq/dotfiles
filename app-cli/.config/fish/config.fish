# Locale
set -gx LANG en_US.UTF-8
set -gx LC_ALL en_US.UTF-8

# Exports
set -gx EDITOR (which nvim)
set -gx VISUAL $EDITOR
set -gx SUDO_EDITOR $EDITOR

# Fish
# set -g fish_greeting
set -U fish_emoji_width 2

# Path
fish_add_path ~/bin
fish_add_path ~/.local/bin
fish_add_path ~/.cargo/bin
fish_add_path ~/.local/share/fnm

set -gx DENO_INSTALL "~/.deno"
fish_add_path $DENO_INSTALL/bin

# Go
set -Ux GOPATH ~/.go
fish_add_path $GOPATH/bin

set -Ux BUN_INSTALL ~/.bun
fish_add_path $BUN_INSTALL/bin

# Commands to run in interactive sessions can go here
if status is-interactive
    # Use starship as Shell Prompt (https://starship.rs/)
    starship init fish | source

    # Start zoxide (https://github.com/ajeetdsouza/zoxide)
    zoxide init fish | source

    # Start fnm (https://github.com/Schniz/fnm)
    fnm env --use-on-cd | source

    # Bindings
    bind \en down-or-search
    bind \ep up-or-search

end

