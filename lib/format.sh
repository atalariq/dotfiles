#!/bin/sh
# Run inside nix develop so discovery and formatting use the pinned toolchain.
set -eu
listing=$(mktemp)
trap 'rm -f -- "$listing"' EXIT HUP INT TERM
if rg --no-config --files -0 -g '*.nix' -g '!**/{hardware-configuration,per-device}.nix' >"$listing"; then
	:
else
	status=$?
	[ "$status" -eq 1 ] || exit "$status"
fi
# NUL-separated paths preserve spaces/newlines; an empty list never runs nixfmt.
xargs -0 sh -c 'test "$#" -eq 0 || exec nixfmt -- "$@"' sh <"$listing"
