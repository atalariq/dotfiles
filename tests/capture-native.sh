#!/usr/bin/env bash
# Optional integration probe: real headless Wayland/IPC/clipboard, private HOME.
# Requires the capture tools and Kitty on PATH; does not activate any profile.
# shellcheck disable=SC2016
set -euo pipefail
desktop=${1:?Usage: capture-native.sh umbriel|mango /path/to/compositor}
compositor=${2:?Compositor executable required}
case "$desktop" in umbriel | mango) ;; *) exit 2 ;; esac
capture=$(cd -- "$(dirname -- "$0")/../modules/home-manager/programs/capture" && pwd)
for tool in kitty grim wl-copy wl-paste magick jq timeout wtype; do command -v "$tool" >/dev/null; done
work=$(mktemp -d "/tmp/dotfiles-$desktop-native.XXXXXX")
mkdir -m 700 "$work/runtime" "$work/home" "$work/bin"
compositor_bin=$(dirname -- "$compositor")
export PATH="$work/bin:$compositor_bin:$PATH"
export XDG_CURRENT_DESKTOP=$desktop XDG_SESSION_ID=desktop-smoke
export ONCE_LOG="$work/once" REPEAT_LOG="$work/repeated" Q_LOG="$work/q"
printf '#!/bin/sh\nprintf x >> "$ONCE_LOG"\n' >"$work/bin/once"
printf '#!/bin/sh\nprintf x >> "$REPEAT_LOG"\n' >"$work/bin/repeated"
printf '#!/bin/sh\nprintf x >> "$Q_LOG"\nexec bash "%s/close" >>"%s/guard.log" 2>&1\n' "$capture" "$work" >"$work/bin/guard"
chmod +x "$work/bin/"*
export HOME="$work/home" XDG_RUNTIME_DIR="$work/runtime" XDG_CONFIG_HOME="$work/home/.config"
export XDG_DATA_HOME="$work/home/.local/share"
export XDG_STATE_HOME="$work/home/.local/state" XDG_CACHE_HOME="$work/home/.cache"
unset DBUS_SESSION_BUS_ADDRESS WAYLAND_SOCKET DISPLAY MANGO_INSTANCE_SIGNATURE UMBRIEL_SOCKET
# Force the nested code path without connecting to the owner's compositor:
# wlroots uses the headless backend, and Umbriel skips host session publication.
export WAYLAND_DISPLAY=isolated-parent-marker WLR_BACKENDS=headless WLR_HEADLESS_OUTPUTS=1
if [[ $desktop == umbriel ]]; then
	printf '[general]\nmod_key = "Super"\nautostart = []\n[output.HEADLESS-1]\nscale = 1.25\n' >"$work/config"
else
	printf 'monitor_rule = name:HEADLESS-1,width:1280,height:720,refresh:60,x:0,y:0,scale:1.25,vrr:0\n' >"$work/config"
fi
if [[ $desktop == umbriel ]]; then
	cat >>"$work/config" <<EOF
[keybinds]
"Ctrl+Mod+Alt+5" = { action = "spawn:$work/bin/once", repeat = false }
"Mod+h" = "spawn:$work/bin/repeated"
"Mod+q" = { action = "spawn:$work/bin/guard", repeat = false }
EOF
else
	cat >>"$work/config" <<EOF
bindns = CTRL+SUPER+ALT,5,spawn,$work/bin/once
binds = SUPER,h,spawn,$work/bin/repeated
bindns = SUPER,q,spawn,$work/bin/guard
EOF
fi
"$compositor" -c "$work/config" >"$work/compositor.log" 2>&1 &
compositor_pid=$!
cleanup() {
	[[ -z ${client_pid:-} ]] || kill "$client_pid" 2>/dev/null || true
	kill "$compositor_pid" 2>/dev/null || true
	wait "$compositor_pid" 2>/dev/null || true
}
trap cleanup EXIT
for _ in $(seq 1 50); do
	[[ ! -S $XDG_RUNTIME_DIR/wayland-0 ]] || break
	if ! kill -0 "$compositor_pid" 2>/dev/null; then
		tail -n 20 "$work/compositor.log"
		exit 1
	fi
	sleep 0.1
done
test -S "$XDG_RUNTIME_DIR/wayland-0"
export WAYLAND_DISPLAY=wayland-0 XDG_CURRENT_DESKTOP=$desktop
compositor_bin=$(dirname -- "$compositor")
export PATH="$work/bin:$compositor_bin:$PATH"
if [[ $desktop == mango ]]; then export MANGO_INSTANCE_SIGNATURE="$XDG_RUNTIME_DIR/mango-$compositor_pid.sock"; fi
printf '#!/bin/sh\nexec sh "%s/window" "$@"\n' "$capture" >"$work/bin/capture-window"
# Notification UI is covered by fixtures/desktop acceptance, not this probe.
printf '#!/bin/sh\nexit 0\n' >"$work/bin/notify-send"
chmod +x "$work/bin/"*
kitty --config NONE --override linux_display_server=wayland --override confirm_os_window_close=0 --title capture-probe \
	-e sh -c 'printf "Isolated screenshot probe\n"; sleep 30' >"$work/client.log" 2>&1 &
client_pid=$!
geometry=
for _ in $(seq 1 50); do
	geometry=$(capture-window geometry 2>/dev/null) && break
	sleep 0.1
done
test -n "$geometry"
printf '%s geometry: %s\n' "$desktop" "$geometry"
for mode in active screen output; do
	timeout 8s bash "$capture/shot" "$mode" 2>&1 | cat
	timeout 5s wl-paste --type image/png >"$work/$mode.png"
	magick identify "$work/$mode.png"
done
if [[ -n ${PLUTO_BIN:-} ]]; then
	dbus-run-session -- sh "$(dirname -- "$0")/shelf-native.sh" "$PLUTO_BIN"
fi
# Real keyboard protocol exercises press/release ordering and compositor repeat.
wtype -M ctrl -M alt -M logo -P 5 -s 1100 -m logo -m alt -m ctrl -p 5
sleep 0.1
test "$(wc -c <"$ONCE_LOG")" = 1
wtype -M ctrl -M alt -M logo -P 5 -s 50 -p 5 -m ctrl -m alt -m logo
sleep 0.1
test "$(wc -c <"$ONCE_LOG")" = 2
wtype -M logo -P h -s 1100 -p h -m logo
sleep 0.1
test "$(wc -c <"$REPEAT_LOG")" -gt 1
# Holding Q must never confirm; a distinct second press must confirm even when
# the first modifier is released before its key.
wtype -M logo -P q -s 1100 -m logo -p q
sleep 0.1
test "$(wc -c <"$Q_LOG")" = 1
kill -0 "$client_pid"
wtype -M logo -P q -s 80 -m logo -p q -s 100 -M logo -k q -m logo
for _ in $(seq 1 50); do
	if ! kill -0 "$client_pid" 2>/dev/null; then break; fi
	sleep 0.02
done
if kill -0 "$client_pid" 2>/dev/null; then
	echo 'Guard did not close the private client' >&2
	exit 1
fi
wait "$client_pid" || true
client_pid=
printf 'Native input: release orders, no-repeat, repeat preservation and guarded close passed.\n'
printf 'Native evidence: %s\n' "$work"
