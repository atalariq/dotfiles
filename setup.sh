#!/bin/sh

ROOT_DIR=${HOME:-/home/atalariq/}

SOURCE=$ROOT_DIR/Repos/dotfiles
TARGET=$ROOT_DIR

stow --dir $SOURCE --target $TARGET -R app-cli
stow --dir $SOURCE --target $TARGET -R app-gui
stow --dir $SOURCE --target $TARGET -R system-general
stow --dir $SOURCE --target $TARGET -R system-archlinux
stow --dir $SOURCE --target $TARGET -R misc-startpage
# stow --dir $SOURCE --target $TARGET -R ui-hyprland
stow --dir $SOURCE --target $TARGET -R ui-gnome


