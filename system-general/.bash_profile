#!/bin/bash

[ -f "$HOME/.profile" ] && source "$HOME/.profile"

# =============================== Themes

export GTK_USE_PORTAL=1
export QT_QPA_PLATFORMTHEME=qt6ct
export _JAVA_AWT_WM_NONEREPARENTING=1

# =============================== WMs
## automatically login to WM
if [[ -z $DISPLAY && $(tty) == /dev/tty2 && $XDG_SESSION_TYPE == tty ]]; then
  export XDG_SESSION_TYPE=x11

  # Start X (~/.xinitrc)
  exec startx

elif [[ -z $DISPLAY && $(tty) == /dev/tty3 && $XDG_SESSION_TYPE == tty ]]; then
  # Hyprland
  # [ -f "$HOME/.xprofile" ] && source $HOME/.xprofile
  # exec Hyprland

  # GNOME
  QT_QPA_PLATFORM=wayland XDG_SESSION_TYPE=wayland \
    exec dbus-run-session gnome-session
fi

export PATH=$PATH:/home/atalariq/.spicetify
