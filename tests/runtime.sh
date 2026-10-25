#!/usr/bin/env bash
# Exercise failure-before-mutation and argv handling with isolated fake tools.
set -euo pipefail
source_root=$1
work=$(mktemp -d)
trap 'rm -rf -- "$work"' EXIT
mkdir -p "$work/bin" "$work/source directory" "$work/destination mount"
export CALL_LOG="$work/rsync-call"
cat >"$work/bin/rsync" <<'SCRIPT'
#!/bin/sh
printf '%s\n' "$@" > "$CALL_LOG"
SCRIPT
chmod +x "$work/bin/rsync"
backup="$source_root/modules/home-manager/programs/_security-scripts/rsync-backup"
if PATH="$work/bin:$PATH" "$backup" "$work/destination mount" "$work/source directory"; then
	echo 'Backup accepted an unmounted destination.' >&2
	exit 1
fi
test ! -e "$CALL_LOG"
export EXPECTED_TARGET="$work/destination mount"
cat >"$work/bin/mountpoint" <<'SCRIPT'
#!/bin/sh
test "$3" = "$EXPECTED_TARGET"
SCRIPT
chmod +x "$work/bin/mountpoint"
PATH="$work/bin:$PATH" "$backup" "$work/destination mount" "$work/source directory"
grep -Fx -- "$work/source directory" "$CALL_LOG"
grep -Fx -- "$work/destination mount/" "$CALL_LOG"

cd "$work"
printf 'source contents' >'original file'
cat >"$work/bin/editor" <<'SCRIPT'
#!/bin/sh
printf '%s\n' 'renamed $(touch injected)' > "$1"
SCRIPT
chmod +x "$work/bin/editor"
VISUAL="$work/bin/editor" bash "$source_root/modules/home-manager/programs/_terminal-scripts/vimv" 'original file'
test -f "renamed \$(touch injected)"
test ! -e injected
# An existing destination is rejected before changing even the first source.
printf a >first
printf b >second
printf occupied >occupied
cat >"$work/bin/editor" <<'SCRIPT'
#!/bin/sh
printf '%s\n' 'first renamed' occupied > "$1"
SCRIPT
if VISUAL="$work/bin/editor" bash "$source_root/modules/home-manager/programs/_terminal-scripts/vimv" first second; then
	echo 'vimv accepted an existing destination.' >&2
	exit 1
fi
test -f first
test -f second
test ! -e 'first renamed'
test "$(cat occupied)" = occupied
# Textual and symlink aliases cannot overwrite another result in the batch.
cat >"$work/bin/editor" <<'SCRIPT'
#!/bin/sh
printf '%s\n' new ./new > "$1"
SCRIPT
if VISUAL="$work/bin/editor" bash "$source_root/modules/home-manager/programs/_terminal-scripts/vimv" first second; then exit 1; fi
test "$(cat first)" = a
test "$(cat second)" = b
test ! -e new
mkdir real
ln -s real alias
cat >"$work/bin/editor" <<'SCRIPT'
#!/bin/sh
printf '%s\n' real/new alias/new > "$1"
SCRIPT
if VISUAL="$work/bin/editor" bash "$source_root/modules/home-manager/programs/_terminal-scripts/vimv" first second; then exit 1; fi
test ! -e real/new
cat >"$work/bin/editor" <<'SCRIPT'
#!/bin/sh
printf '%s\n' new new/sub > "$1"
SCRIPT
if VISUAL="$work/bin/editor" bash "$source_root/modules/home-manager/programs/_terminal-scripts/vimv" first second; then exit 1; fi
test ! -e new
mkdir dir-a dir-b
printf nested >dir-a/item
cat >"$work/bin/editor" <<'SCRIPT'
#!/bin/sh
printf '%s\n' dir-b/x dir-c > "$1"
SCRIPT
if VISUAL="$work/bin/editor" bash "$source_root/modules/home-manager/programs/_terminal-scripts/vimv" dir-a dir-b; then exit 1; fi
test "$(cat dir-a/item)" = nested
test -d dir-b
test ! -e dir-c
# Successful tracked moves preserve Git's staged rename semantics.
git init -q tracked
cd tracked
git config user.email fixture@example.invalid
git config user.name Fixture
printf tracked >original
git add original
git commit -qm initial
cat >"$work/bin/editor" <<'SCRIPT'
#!/bin/sh
printf '%s\n' changed > "$1"
SCRIPT
VISUAL="$work/bin/editor" bash "$source_root/modules/home-manager/programs/_terminal-scripts/vimv" original
test "$(cat changed)" = tracked
git diff --cached --name-status | grep -F 'R100'
# Resolve parent symlinks before '..', while keeping the leaf entry itself.
cd "$work"
mkdir -p physical/nested
ln -s "$work/physical/nested" parent-alias
cat > "$work/bin/editor" <<'SCRIPT'
#!/bin/sh
printf '%s\n' parent-alias/../correct > "$1"
SCRIPT
VISUAL="$work/bin/editor" bash "$source_root/modules/home-manager/programs/_terminal-scripts/vimv" first
test "$(cat physical/correct)" = a
test ! -e correct
