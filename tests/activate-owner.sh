#!/usr/bin/env bash
set -euo pipefail
script=$1
work=$(mktemp -d)
trap 'rm -rf -- "$work"' EXIT
export CASE_WORK=$work REAL_READLINK XDG_STATE_HOME="$work/user-state"
REAL_READLINK=$(command -v readlink)
mkdir "$work/bin" "$work/state"
state=$work/state
chmod 700 "$state"
jq -n --arg owner "$(id -un)" '{source:"/nix/store/fixture-source",host:"fixture",owner:$owner,system:"/nix/store/fixture-system",generation:"/nix/store/fixture-home"}' >"$state/plan.json"
cat >"$work/bin/cutover" <<'SH'
#!/bin/sh
[ "${DOTFILES_CUTOVER_LOCK_STATE:-}" = "$2" ] || exit 88
if flock -n "$2/lock" true; then exit 89; fi
printf '%s\n' "$1" >>"$CASE_WORK/calls"
case "$1" in
status) exit 0 ;;
relocate) [ "${FAIL_RELOCATE:-0}" = 0 ] || exit 5 ;;
rollback) exit 0 ;;
esac
SH
cat >"$work/bin/sudo" <<'SH'
#!/bin/sh
printf 'sudo:%s\n' "$*" >>"$CASE_WORK/calls"
case "$1" in
-v) [ "${FAIL_AUTH:-0}" = 0 ] ;;
-n)
  if flock -n "$CASE_WORK/state/lock" true; then exit 89; fi
  [ "${FAIL_SWITCH:-0}" = 0 ] ;;
*) exit 99 ;;
esac
SH
cat >"$work/bin/systemctl" <<'SH'
#!/bin/sh
[ "${FAIL_VERIFY:-0}" = 0 ] || exit 1
case "$*" in *ExecMainStatus*) echo 0 ;; *) echo success ;; esac
SH
cat >"$work/bin/readlink" <<'SH'
#!/bin/sh
case "$*" in
"-f $XDG_STATE_HOME/home-manager/gcroots/current-home") if [ "${FAIL_HOME:-0}" = 1 ]; then echo /nix/store/old-home; else echo /nix/store/fixture-home; fi ;;
'-f /run/current-system'|'-f /nix/var/nix/profiles/system') echo /nix/store/fixture-system ;;
*) exec "$REAL_READLINK" "$@" ;;
esac
SH
chmod +x "$work/bin/"*
export PATH="$work/bin:$PATH"
reset_case() {
	: >"$work/calls"
	printf '{"status":"prepared"}\n' >"$state/status.json"
	rm -rf "$state/activation-result.json"
}
reset_case
if FAIL_AUTH=1 bash "$script" "$state" "$work/bin/cutover"; then exit 1; fi
if grep -Fx relocate "$work/calls"; then exit 1; fi
reset_case
if FAIL_RELOCATE=1 bash "$script" "$state" "$work/bin/cutover"; then exit 1; fi
if grep -F 'sudo:-n' "$work/calls"; then exit 1; fi
reset_case
if FAIL_SWITCH=1 bash "$script" "$state" "$work/bin/cutover"; then exit 1; fi
grep -Fx rollback "$work/calls"
test "$(jq -r .result "$state/activation-result.json")" = failed
reset_case
mkdir "$state/activation-result.json"
if FAIL_SWITCH=1 bash "$script" "$state" "$work/bin/cutover"; then exit 1; fi
grep -Fx rollback "$work/calls"
reset_case
if FAIL_VERIFY=1 bash "$script" "$state" "$work/bin/cutover"; then exit 1; fi
grep -Fx rollback "$work/calls"
reset_case
if FAIL_HOME=1 bash "$script" "$state" "$work/bin/cutover"; then exit 1; fi
grep -Fx rollback "$work/calls"
reset_case
bash "$script" "$state" "$work/bin/cutover"
if grep -Fx rollback "$work/calls"; then exit 1; fi
test "$(jq -r .result "$state/activation-result.json")" = activated
test "$(sed -n '2p' "$work/calls")" = sudo:-v
test "$(sed -n '3p' "$work/calls")" = relocate
printf 'Owner handoff: auth, relocation, switch failure, verification and rollback passed.\n'
