#!/bin/sh
# vim: ft=sh ts=4 sw=4:

USER_XRESOURCES=$HOME/.Xresources
SYS_XRESOURCES=/etc/X11/xinit/.Xresources
USER_XMODMAP=$HOME/.Xmodmap
SYS_XMODMAP=/etc/X11/xinit/.Xmodmap

[ -f $SYS_XRESOURCES ] && xrdb -merge $SYS_XRESOURCES
[ -f $SYS_XMODMAP ] && xmodmap $SYS_XMODMAP
[ -f "$USER_XRESOURCES" ] && xrdb -merge "$USER_XRESOURCES"
[ -f "$USER_XMODMAP" ] && xmodmap "$USER_XMODMAP"

# start some nice programs
if [ -d /etc/X11/xinit/xinitrc.d ] ; then
    for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

[ -f "$HOME/.xprofile" ] && . "$HOME/.xprofile"

# Initialization
# xsetroot -cursor_name left_ptr      # Change X shaped default cursor
# xset -b                             # Disable terminal bell
xset r rate 300 50 &                # Set repeat rate

# ========== AwesomeWM
# exec awesome

# ========== Cinnamon
# gsettings set org.cinnamon.desktop.wm.preferences num-workspaces 4
# gsettings set org.nemo.desktop show-desktop-icons true
# gsettings set org.cinnamon.desktop.wm.preferences resize-with-right-button true
# exec cinnamon-session

# ========== GNOME
# export XDG_SESSION_TYPE=x11
# export GDK_BACKEND=x11
# exec gnome-session

# ========== GNOME Classic
# export XDG_CURRENT_DESKTOP=GNOME-Classic:GNOME
# export GNOME_SHELL_SESSION_MODE=classic
# exec gnome-session

