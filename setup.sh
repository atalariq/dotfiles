#!/bin/sh

SOURCE=/home/atalariq/Repos/dotfiles
TARGET=/home/atalariq

stow --dir $SOURCE --target $TARGET -R app-cli
stow --dir $SOURCE --target $TARGET -R app-gui
stow --dir $SOURCE --target $TARGET -R app-nvim
stow --dir $SOURCE --target $TARGET -R system
stow --dir $SOURCE --target $TARGET -R system-archlinux
stow --dir $SOURCE --target $TARGET -R wm-hyprland


