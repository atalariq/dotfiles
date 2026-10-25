#!/usr/bin/env bash
set -euo pipefail
formatter=$1
work=$(mktemp -d)
trap 'rm -rf -- "$work"' EXIT
mkdir -p "$work/bin" "$work/tree/sub dir"
export FORMAT_CALLS="$work/calls"
cat >"$work/bin/nixfmt" <<'SH'
#!/bin/sh
test "$1" = --
shift
printf '%s\0' "$@" >>"$FORMAT_CALLS"
SH
chmod +x "$work/bin/nixfmt"
export PATH="$work/bin:$PATH"
cd "$work/tree"
sh "$formatter"
test ! -e "$FORMAT_CALLS"
touch 'sub dir/a file.nix' 'sub dir/hardware-configuration.nix' 'per-device.nix'
sh "$formatter"
mapfile -d '' -t paths <"$FORMAT_CALLS"
test "${#paths[@]}" = 1
test "${paths[0]}" = 'sub dir/a file.nix'
rm "$FORMAT_CALLS"
cat >"$work/bin/rg" <<'SH'
#!/bin/sh
printf 'partial.nix\0'
exit 2
SH
chmod +x "$work/bin/rg"
if sh "$formatter"; then
	echo 'Accepted discovery failure' >&2
	exit 1
fi
test ! -e "$FORMAT_CALLS"
printf 'Formatter: empty lists, spaced paths, exclusions and scan failure passed.\n'
