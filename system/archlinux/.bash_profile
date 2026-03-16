#!/bin/bash

[ -f "$HOME/.profile" ] && . "$HOME/.profile"

# automatically login to WM
if [[ -z $DISPLAY && $(tty) == /dev/tty1 && $XDG_SESSION_TYPE == tty ]]; then
  export XDG_SESSION_TYPE=wayland
  export QT_QPA_PLATFORMTHEME=qt6ct

  # exec niri-session
  exec mango
elif [[ -z $DISPLAY && $(tty) == /dev/tty2 && $XDG_SESSION_TYPE == tty ]]; then
  exec start-cosmic
fi


# `distrobox enter <profile>` solution so I can use my preferred interactive shell
[ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"
