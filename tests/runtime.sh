#!/usr/bin/env bash
# Exercise failure-before-mutation and argv handling with isolated fake tools.
set -euo pipefail
source_root=$1
work=$(mktemp -d)
trap 'rm -rf -- "$work"' EXIT
mkdir -p "$work/bin" "$work/source directory" "$work/destination mount"
export CALL_LOG="$work/rsync-call"
cat > "$work/bin/rsync" <<'SCRIPT'
#!/bin/sh
printf '%s\n' "$@" > "$CALL_LOG"
SCRIPT
chmod +x "$work/bin/rsync"
backup="$source_root/modules/home-manager/security/scripts/rsync-backup"
if PATH="$work/bin:$PATH" "$backup" "$work/destination mount" "$work/source directory"; then
  echo 'Backup accepted an unmounted destination.' >&2
  exit 1
fi
test ! -e "$CALL_LOG"
export EXPECTED_TARGET="$work/destination mount"
cat > "$work/bin/mountpoint" <<'SCRIPT'
#!/bin/sh
test "$3" = "$EXPECTED_TARGET"
SCRIPT
chmod +x "$work/bin/mountpoint"
PATH="$work/bin:$PATH" "$backup" "$work/destination mount" "$work/source directory"
grep -Fx -- "$work/source directory" "$CALL_LOG"
grep -Fx -- "$work/destination mount/" "$CALL_LOG"

cd "$work"
printf 'source contents' > 'original file'
cat > "$work/bin/editor" <<'SCRIPT'
#!/bin/sh
printf '%s\n' 'renamed $(touch injected)' > "$1"
SCRIPT
chmod +x "$work/bin/editor"
VISUAL="$work/bin/editor" bash "$source_root/modules/home-manager/terminal/scripts/vimv" 'original file'
test -f "renamed \$(touch injected)"
test ! -e injected
# An existing destination is rejected before changing even the first source.
printf a > first
printf b > second
printf occupied > occupied
cat > "$work/bin/editor" <<'SCRIPT'
#!/bin/sh
printf '%s\n' 'first renamed' occupied > "$1"
SCRIPT
if VISUAL="$work/bin/editor" bash "$source_root/modules/home-manager/terminal/scripts/vimv" first second; then
  echo 'vimv accepted an existing destination.' >&2
  exit 1
fi
test -f first
test -f second
test ! -e 'first renamed'
test "$(cat occupied)" = occupied
