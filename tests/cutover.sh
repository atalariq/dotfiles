#!/usr/bin/env bash
set -euo pipefail
source_root=$1
work=$(mktemp -d)
trap 'rm -rf -- "$work"' EXIT
export TEST_WORK=$work
REAL_READLINK=$(command -v readlink)
REAL_STAT=$(command -v stat)
export REAL_STAT
REAL_MV=$(command -v mv)
export REAL_READLINK REAL_MV
export TEST_SYSTEM="$work/system" TEST_GENERATION="$work/generation" TEST_SOURCE="$work/source" TEST_RECOVERY="$work/recovery"
export AUDIT_SCRIPT="$source_root/lib/audit-home.sh"
mkdir -p "$work/bin" "$TEST_SYSTEM/bin" "$TEST_GENERATION/home-files/.config/parent" "$TEST_SOURCE" "$TEST_RECOVERY"
printf '#!/bin/sh\nexit 0\n' >"$TEST_SYSTEM/bin/switch-to-configuration"
chmod +x "$TEST_SYSTEM/bin/switch-to-configuration"
printf declared >"$TEST_GENERATION/home-files/.bashrc"
printf declared >"$TEST_GENERATION/home-files/.config/app"
printf declared >"$TEST_GENERATION/home-files/.config/parent/setting"
cat >"$work/bin/nix" <<'SH'
#!/bin/sh
case "$*" in
'flake metadata'*) printf '{"path":"%s"}\n' "$TEST_SOURCE" ;;
*config.system.build.toplevel.outPath*) echo "$TEST_SYSTEM" ;;
*username*) id -un ;;
*home.activationPackage.outPath*) echo "$TEST_GENERATION" ;;
*) exit 2 ;;
esac
SH
cat >"$work/bin/nix-store" <<'SH'
#!/bin/sh
ln -s -- "$2" "$4"
SH
cat >"$work/bin/readlink" <<'SH'
#!/bin/sh
case "$*" in
'-f /run/current-system'|'-f /run/booted-system'|'-f /nix/var/nix/profiles/system') echo "$TEST_RECOVERY" ;;
*) exec "$REAL_READLINK" "$@" ;;
esac
SH
cat >"$work/bin/dotfiles-audit-home" <<'SH'
#!/bin/sh
exec sh "$AUDIT_SCRIPT" "$@"
SH
cat >"$work/bin/mv" <<'SH'
#!/bin/sh
previous=
for arg do source=$previous; previous=$arg; done
if [ "${FAIL_MOVE:-0}" = 1 ] && [ "$source" = "$HOME/.config/app" ] && [ ! -e "$TEST_WORK/failed-once" ]; then
  touch "$TEST_WORK/failed-once"
  exit 5
fi
exec "$REAL_MV" "$@"
SH
cat >"$work/bin/stat" <<'SH'
#!/bin/sh
if [ "${CROSS_DEVICE:-0}" = 1 ] && [ "$*" = "-c %d -- $HOME/.bashrc" ]; then
  echo 999999
else exec "$REAL_STAT" "$@"
fi
SH
chmod +x "$work/bin/"*
export PATH="$work/bin:$PATH"
fixture() {
	export HOME="$work/home-$1" XDG_STATE_HOME="$work/state-$1"
	mkdir -p "$HOME/.config" "$work/owner-$1"
	printf original >"$HOME/.bashrc"
	printf app-owner >"$HOME/.config/app"
	printf custom >"$work/owner-$1/unmanaged"
	ln -s "$work/owner-$1" "$HOME/.config/parent"
}
cutover() { bash "$source_root/lib/cutover.sh" "$@"; }
prepare() { cutover prepare fixture "$TEST_SYSTEM" "$TEST_GENERATION" "$HOME"; }
assert_original() {
	test "$(cat "$HOME/.bashrc")" = original
	test "$(cat "$HOME/.config/app")" = app-owner
	test -L "$HOME/.config/parent"
	test "$(cat "$HOME/.config/parent/unmanaged")" = custom
}
fixture cross-device
if CROSS_DEVICE=1 prepare; then exit 1; fi
assert_original
fixture device-changed
state=$(prepare)
if CROSS_DEVICE=1 cutover relocate "$state"; then exit 1; fi
assert_original
test "$(find "$state/journal" -name '*.json' | wc -l)" = 0
fixture success
state=$(prepare)
assert_original
test "$(find "$state/roots" -type l | wc -l)" = 6
cutover relocate "$state"
test ! -e "$HOME/.bashrc"
ln -s "$TEST_GENERATION/home-files/.bashrc" "$HOME/.bashrc"
ln -s "$TEST_GENERATION/home-files/.config/app" "$HOME/.config/app"
mkdir "$HOME/.config/parent"
ln -s "$TEST_GENERATION/home-files/.config/parent/setting" "$HOME/.config/parent/setting"
cutover rollback "$state"
assert_original
test -L "$state/installed/.bashrc"
# An I/O failure after the first move automatically restores completed entries.
fixture partial
state=$(prepare)
if FAIL_MOVE=1 cutover relocate "$state"; then exit 1; fi
assert_original
test "$(jq -r .status "$state/status.json")" = restored
# Recover a process killed after mv but before its completion record.
fixture interrupted
state=$(prepare)
jq '.[0] + {status:"intent"}' "$state/identities.json" >"$state/journal/000000.json"
relative=$(jq -r .relative "$state/journal/000000.json")
mkdir -p "$(dirname "$state/relocated/$relative")"
"$REAL_MV" "$HOME/$relative" "$state/relocated/$relative"
cutover rollback "$state"
assert_original
# Unknown post-relocation user files are never replaced by rollback.
fixture collision
state=$(prepare)
cutover relocate "$state"
printf new-owner-data >"$HOME/.config/app"
if cutover rollback "$state"; then exit 1; fi
test "$(cat "$HOME/.config/app")" = new-owner-data
test "$(cat "$state/relocated/.config/app")" = app-owner
test "$(jq -r .status "$state/status.json")" = rollback-blocked
fixture changed
state=$(prepare)
printf changed >>"$HOME/.bashrc"
if cutover relocate "$state"; then exit 1; fi
test "$(cat "$HOME/.bashrc")" = originalchanged
test "$(find "$state/journal" -name '*.json' | wc -l)" = 0
fixture corrupt
state=$(prepare)
printf damaged >>"$state/home-links.tar"
if cutover relocate "$state"; then exit 1; fi
assert_original
printf 'Cutover: retention, relocation, rollback, interruptions and collision refusal passed.\n'

# The activation parent and its children share a lock; unrelated rollback cannot race.
fixture serialized
state=$(prepare)
(
	exec 9>"$state/lock"
	flock -n 9
	export DOTFILES_CUTOVER_LOCK_STATE=$state
	cutover status "$state"
	if (
		unset DOTFILES_CUTOVER_LOCK_STATE
		cutover rollback "$state"
	); then exit 1; fi
	cutover relocate "$state"
	if (
		unset DOTFILES_CUTOVER_LOCK_STATE
		cutover rollback "$state"
	); then exit 1; fi
	cutover rollback "$state"
)
assert_original
printf 'Cutover: inherited lock and concurrent rollback refusal passed.\n'
