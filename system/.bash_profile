#!/bin/bash

[ -f "${XDG_CONFIG_HOME:-$HOME/.config}"/shell/profile ] && source "${XDG_CONFIG_HOME:-$HOME/.config}"/shell/profile
[ -f "$HOME/.profile" ] && source "$HOME/.profile"


# =============================== Themes
# export GTK_USE_PORTAL=1
# export GTK2_RC_FILES="${XDG_CONFIG_HOME:-$HOME/.config}/gtk-2.0/gtkrc-2.0"
# export GTK3_RC_FILES="${XDG_CONFIG_HOME:-$HOME/.config}/gtk-3.0/settings.ini"
# export GTK4_RC_FILES="${XDG_CONFIG_HOME:-$HOME/.config}/gtk-4.0/settings.ini"

# export QT_QPA_PLATFORMTHEME=qt5ct
# export QT_AUTO_SCREEN_SCALE_FACTOR=1
# export QT_SCALE_FACTOR=1
# export QT_SCREEN_SCALE_FACTORS=1
# export QT_FONT_DPI=96

export _JAVA_AWT_WM_NONEREPARENTING=1

# =============================== WMs
## automatically login to WM
if [[ -z $DISPLAY && $(tty) == /dev/tty2 && $XDG_SESSION_TYPE == tty ]]; then
  export XDG_SESSION_TYPE=x11

  # Start X (~/.xinitrc)
  exec startx

elif [[ -z $DISPLAY && $(tty) == /dev/tty3 && $XDG_SESSION_TYPE == tty ]]; then
  # export XDG_SESSION_TYPE=wayland
  #
  # export QT_QPA_PLATFORM=wayland
  # export CLUTTER_BACKEND=wayland
  # export GDK_BACKEND=wayland
  # export SDL_VIDEODRIVER=wayland
  # export WINIT_UNIX_BACKEND=x11

  # Hyprland
  # [ -f "$HOME/.xprofile" ] && source $HOME/.xprofile
  exec Hyprland

  # GNOME
  # MOZ_ENABLE_WAYLAND=1 QT_QPA_PLATFORM=wayland XDG_SESSION_TYPE=wayland \
  #   exec dbus-run-session gnome-session
fi
