#!/bin/bash

[ -f "$HOME/.profile" ] && . "$HOME/.profile"

__wayland_set_env() {
  export AWT_TOOLKIT=MLToolkit
  export QT_QPA_PLATFORM="Wayland;xcb"
  export QT_QPA_PLATFORMTHEME=qt6ct
  export XDG_SESSION_TYPE=wayland
  export _JAVA_AWT_WM_NONREPARENTING=1
}

# automatically login to WM
if [[ -z $DISPLAY && $(tty) == /dev/tty1 && $XDG_SESSION_TYPE == tty ]]; then
  __wayland_set_env

  XDG_CURRENT_DESKTOP=mango exec mango
elif [[ -z $DISPLAY && $(tty) == /dev/tty2 && $XDG_SESSION_TYPE == tty ]]; then
  __wayland_set_env
  export XDG_CURRENT_DESKTOP=GNOME

  # exec dbus-run-session -- gnome-shell --display-server --wayland
  XDG_CURRENT_DESKTOP=GNOME exec dbus-run-session gnome-session --session=gnome-wayland
elif [[ -z $DISPLAY && $(tty) == /dev/tty3 && $XDG_SESSION_TYPE == tty ]]; then
  ~/.local/script/server-mode
fi

# SSH agent (systemd user service) — enter passphrase once per session
export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent.socket"
ssh-add -l > /dev/null 2>&1 || ssh-add ~/.ssh/atalariq_mac_ed25519



# Added by Antigravity CLI installer
export PATH="/home/atalariq/.local/bin:$PATH"
