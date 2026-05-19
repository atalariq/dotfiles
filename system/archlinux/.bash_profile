#!/bin/bash

[ -f "$HOME/.profile" ] && . "$HOME/.profile"

# automatically login to WM
if [[ -z $DISPLAY && $(tty) == /dev/tty1 && $XDG_SESSION_TYPE == tty ]]; then
  export XDG_SESSION_TYPE=wayland
  export QT_QPA_PLATFORMTHEME=qt6ct
  export GDK_SCALE=1

  # exec niri-session
  exec mango
elif [[ -z $DISPLAY && $(tty) == /dev/tty2 && $XDG_SESSION_TYPE == tty ]]; then
  export QT_QPA_PLATFORM="Wayland;xcb"
  export QT_QPA_PLATFORMTHEME=qt6ct
  export _JAVA_AWT_WM_NONREPARENTING=1
  export AWT_TOOLKIT=MLToolkit
  export XDG_SESSION_TYPE=wayland

  export XDG_CURRENT_DESKTOP=GNOME
  export GDK_SCALE=2
  # exec dbus-run-session -- gnome-shell --display-server --wayland
  exec dbus-run-session gnome-session --session=gnome-wayland
elif [[ -z $DISPLAY && $(tty) == /dev/tty3 && $XDG_SESSION_TYPE == tty ]]; then
  ~/.local/script/server-mode
fi


# `distrobox enter <profile>` solution so I can use my preferred interactive shell
[ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"
