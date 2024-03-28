#!/bin/sh
# vim: ft=sh ts=4 sw=4:
# shellcheck disable=SC2155,SC1091

# =========================================== Locale
CHARSET=UTF-8
LANG=en_US.UTF-8
export MM_CHARSET=$CHARSET
export LANG=$LANG
export LC_ALL=$LANG
# export LOCALE_ARCHIVE=/usr/lib/locale/locale-archive

# =========================================== Driver
export LIBVA_DRIVER_NAME=iHD
export WEYLUS_VAAPI_DEVICE=/dev/dri/renderD129

# ========================================== Directory
# ------- XDG
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

[ -f "$XDG_CONFIG_HOME/user-dirs.dirs" ] && . "$XDG_CONFIG_HOME/user-dirs.dirs"

# ------- Clean-up ~/
export ANDROID_SDK_HOME="${XDG_CONFIG_HOME:-$HOME/.config}/android"
export CARGO_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/cargo"
export GOPATH="${XDG_DATA_HOME:-$HOME/.local/share}/go"
export GOBIN="$GOPATH/bin"
export GNUPGHOME="${XDG_DATA_HOME:-$HOME/.local/share}/gnupg"
export HISTFILE="${XDG_DATA_HOME:-$HOME/.local/share}/history"
export ICEAUTHORITY="${XDG_CACHE_HOME}/ICEauthority"
# export INPUTRC="${XDG_CONFIG_HOME:-$HOME/.config}/shell/inputrc"
export LESSHISTFILE="${XDG_CONFIG_HOME:-$HOME/.config}/less/history"
export LESSKEY="${XDG_CONFIG_HOME:-$HOME/.config}/less/keys"
# export NOTMUCH_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/notmuch-config"
export PASSWORD_STORE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/password-store"
export TERMINFO="${XDG_DATA_HOME:-$HOME/.local/share}/terminfo"
# export TMUX_TMPDIR="$XDG_RUNTIME_DIR"
# export WWW_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/w3m"
# export WGETRC="${XDG_CONFIG_HOME:-$HOME/.config}/wget/wgetrc"

# ========================================== Apss
# export QT_QPA_PLATFORM=gnome
# export QT_QPA_PLATFORM="wayland;xcb"
export QT_QPA_PLATFORM=wayland
export QT_QPA_PLATFORMTHEME=qt6ct
# export QT_STYLE_OVERRIDE=adwaita
# export QT_WAYLAND_DECORATION=adwaita
# export GTK_USE_PORTAL=1

# -------- CLI
export EDITOR="nvim"
export VISUAL=$EDITOR
export SUDO_EDITOR=$EDITOR
export PAGER="less -R"
export LESS="-R"
export BAT_PAGER="$PAGER"
export DELTA_PAGER="$PAGER"
export SUDO_PROMPT="$(tput bold setab 1 setaf 0)(sudo)$(tput sgr0) $(tput setaf 6)password for$(tput sgr0) $(tput setaf 3)%p$(tput sgr0): "

# ------- Command
export PERMISSION="sudo"
export SHUTDOWN_CMD="poweroff"
export REBOOT_CMD="reboot"
export SUSPEND_CMD="systemctl suspend"
export LOCK_CMD="lock"

# ------- clipmenu
export CM_DIR=/tmp/clipmenu
export CM_HISTLENGTH=20
export CM_LAUNCHER="rofi"
export CM_SELECTIONS="clipboard"

# ------ fcitx
# export GLFW_IM_MODULE="ibus"
# export GTK_IM_MODULE="fcitx"
# export QT_IM_MODULE="fcitx"
# export XMODIFIERS="@im=fcitx"
# export SDL_IM_MODULE="fcitx"
# export IBUS_USE_PORTAL=1

# ================================ Code
# ----- Golang
export CC="gcc"

# ----- NodeJS
export npm_config_prefix="$HOME/.local"

# ---- Bun
export BUN_INSTALL="$HOME/.bun"

# ================================ PATH {{{
TO_PATH() {
	if [ -d "$1" ]; then
		if ! printf "%s" "$PATH" | grep -q "$1"; then
			export PATH="$PATH:$1"
		fi
	fi
}

TO_PATH "$HOME/Applications"
TO_PATH "$HOME/bin"
TO_PATH "$HOME/.local/bin"
TO_PATH "$HOME/.local/script"
TO_PATH "$HOME/.local/sdk/flutter"
TO_PATH "$CARGO_HOME/bin"
TO_PATH "$GOBIN"
TO_PATH "$BUN_INSTALL/bin"

# }}}

# ============================= Others

# Misc
export CHROME_PATH=/usr/bin/google-chrome-stable
export CHROME_EXECUTABLE=/usr/bin/google-chrome-stable

# API/TOKEN
get_token() {
	[ -f "$1" ] && cat "$1" || echo ""
}

## Required by AwesomeWM
export OPEN_WEATHER_MAP_API_KEY="$(get_token "$HOME"/.key/openweather_api.txt)"
export OPEN_WEATHER_MAP_CITY_ID="$(get_token "$HOME"/.key/openweather_city_id.txt)"
export COUNTRY="$(get_token "$HOME"/.key/openweather_city.txt)"
export CITY="$(get_token "$HOME"/.key/openweather_country.txt)"

## wtf
export WTF_OWM_API_KEY="$OPEN_WEATHER_MAP_API_KEY"
