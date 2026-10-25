#!/usr/bin/env bash
set -euo pipefail
audit=$1
work=$(mktemp -d)
trap 'rm -r -- "$work"' EXIT
mkdir -p "$work/generation/home-files/.config/alpha" "$work/home" "$work/generation/home-files/.config/MangoHud" "$work/generation/home-files/.config/mango"
printf declared >"$work/generation/home-files/.config/alpha/settings"
printf declared >"$work/generation/home-files/.config/MangoHud/settings"
printf declared >"$work/generation/home-files/.config/mango/settings"
locale -a | grep -i '^en_US\.utf8$'
LC_ALL=C sh "$audit" "$work/generation" "$work/home" >"$work/c"
LC_ALL=en_US.utf8 sh "$audit" "$work/generation" "$work/home" >"$work/us"
cmp "$work/c" "$work/us"
printf 'HOME audit is byte-identical across C and en_US locales.\n'
