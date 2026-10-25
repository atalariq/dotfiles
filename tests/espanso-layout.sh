#!/usr/bin/env bash
# Exercise HM's real collision checker against an Espanso-created runtime tree.
set -euo pipefail
generation=${1:?Home Manager generation required}
work=$(mktemp -d)
trap 'rm -rf -- "$work"' EXIT
export HOME=$work/home HOME_MANAGER_BACKUP_COMMAND= HOME_MANAGER_BACKUP_EXT= HOME_MANAGER_BACKUP_OVERWRITE=
mkdir -p "$HOME/.config/espanso/match/packages"
printf 'runtime state\n' >"$HOME/.config/espanso/match/packages/sentinel"
files=$(readlink -e "$generation/home-files")
checker=$(sed -n 's/.*-exec bash \([^ ]*-check-link-targets.sh\).*/\1/p' "$generation/activate")
[[ -f $checker ]]
find "$files/.config/espanso/match" \( -type f -o -type l \) -exec bash "$checker" "$files" {} +
[[ ! -L $files/.config/espanso/match ]]
grep -Fx 'runtime state' "$HOME/.config/espanso/match/packages/sentinel"
printf 'Espanso runtime packages coexist with generated HM file links.\n'
