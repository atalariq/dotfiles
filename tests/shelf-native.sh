#!/bin/sh
# Called on a private D-Bus and headless compositor by capture-native.sh.
set -eu
pluto=${1:?Pluto executable}
mkdir -p "$XDG_CONFIG_HOME/pluto" "$HOME/folder"
printf 'shake = false\n' >"$XDG_CONFIG_HOME/pluto/config.toml"
touch "$HOME/file"
"$pluto" >"$HOME/pluto.log" 2>&1 &
pid=$!
trap 'kill "$pid" 2>/dev/null || true; wait "$pid" 2>/dev/null || true' EXIT
# `gdbus wait` verifies application registration, not a guessed startup delay.
timeout 8 gdbus wait --session io.pluto.Pluto
owner=$(gdbus call --session --dest org.freedesktop.DBus --object-path /org/freedesktop/DBus --method org.freedesktop.DBus.GetNameOwner io.pluto.Pluto)
"$pluto" toggle
"$pluto" add "$HOME/file" "$HOME/folder" 'shelf test text' 'https://example.com/'
"$pluto" hide
other=$(gdbus call --session --dest org.freedesktop.DBus --object-path /org/freedesktop/DBus --method org.freedesktop.DBus.GetNameOwner io.pluto.Pluto)
[ "$owner" = "$other" ]
"$pluto" add "last pending change"
if [ -n "${PLUTO_STOP:-}" ]; then
	sh "$PLUTO_STOP" "$pid"
else
	"$pluto" quit
fi
wait "$pid"
state="$HOME/.local/share/pluto/state.json"
jq -e '[.shelves[].items[]] | length == 5 and any(.[]; .kind == "text") and any(.[]; .kind == "url") and ([.[] | select(.kind == "file")] | length == 2)' "$state"
# User state survives a fresh process; opening it does not replace the shelf.
"$pluto" >"$HOME/pluto-restart.log" 2>&1 &
pid=$!
timeout 8 gdbus wait --session io.pluto.Pluto
if [ -n "${PLUTO_STOP:-}" ]; then
	sh "$PLUTO_STOP" "$pid"
else
	"$pluto" quit
fi
wait "$pid"
jq -e '[.shelves[].items[]] | length == 5' "$state"
printf 'Pluto: singleton, toggle, add, writable persistence and restart passed.\n'
