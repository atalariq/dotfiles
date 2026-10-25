#!/usr/bin/env bash
set -euo pipefail
script=$1
work=$(mktemp -d)
trap 'rm -rf -- "$work"' EXIT
export CASE_WORK=$work REAL_READLINK XDG_STATE_HOME="$work/user-state"
REAL_READLINK=$(command -v readlink)
mkdir "$work/bin" "$work/state"
export TEST_GENERATION="$work/generation"
mkdir -p "$TEST_GENERATION/home-files/.config/espanso/match"
state=$work/state
chmod 700 "$state"
jq -n --arg generation "$TEST_GENERATION" --arg owner "$(id -un)" '{source:"/nix/store/fixture-source",host:"fixture",owner:$owner,system:"/nix/store/fixture-system",generation:$generation}' >"$state/plan.json"
cat >"$work/bin/cutover" <<'SH'
#!/bin/sh
[ "${DOTFILES_CUTOVER_LOCK_STATE:-}" = "$2" ] || exit 88
if flock -n "$2/lock" true; then exit 89; fi
printf '%s\n' "$1" >>"$CASE_WORK/calls"
case "$1" in
status) exit 0 ;;
relocate) [ "${FAIL_RELOCATE:-0}" = 0 ] || exit 5 ;;
rollback) [ "${FAIL_ROLLBACK:-0}" = 0 ] || exit 6 ;;
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
if [ "$1" = --user ]; then
  case "$2" in
    is-active) [ "${ESPANSO_ACTIVE:-0}" = 1 ] ;;
    stop|start)
      printf 'espanso:%s\n' "$2" >>"$CASE_WORK/calls"
      if [ "$2" = stop ]; then [ "${FAIL_STOP:-0}" = 0 ]; else [ "${FAIL_START:-0}" = 0 ]; fi ;;
    *) exit 99 ;;
  esac
  exit $?
fi
[ "${FAIL_VERIFY:-0}" = 0 ] || exit 1
case "$*" in *ExecMainStatus*) echo 0 ;; *) echo success ;; esac
SH
cat >"$work/bin/readlink" <<'SH'
#!/bin/sh
case "$*" in
"-f $XDG_STATE_HOME/home-manager/gcroots/current-home") if [ "${FAIL_HOME:-0}" = 1 ]; then echo /nix/store/old-home; else echo "$TEST_GENERATION"; fi ;;
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

reset_case
ESPANSO_ACTIVE=1 bash "$script" "$state" "$work/bin/cutover"
test "$(sed -n '3p' "$work/calls")" = espanso:stop
test "$(sed -n '4p' "$work/calls")" = relocate
test "$(tail -n 1 "$work/calls")" = espanso:start
reset_case
if ESPANSO_ACTIVE=1 FAIL_SWITCH=1 bash "$script" "$state" "$work/bin/cutover"; then exit 1; fi
test "$(tail -n 2 "$work/calls")" = "$(printf 'rollback\nespanso:start')"
reset_case
if ESPANSO_ACTIVE=1 FAIL_STOP=1 bash "$script" "$state" "$work/bin/cutover"; then exit 1; fi
if grep -Fx relocate "$work/calls"; then exit 1; fi
grep -Fx espanso:start "$work/calls"
reset_case
if ESPANSO_ACTIVE=1 FAIL_SWITCH=1 FAIL_ROLLBACK=1 bash "$script" "$state" "$work/bin/cutover"; then exit 1; fi
if grep -Fx espanso:start "$work/calls"; then exit 1; fi
reset_case
if ESPANSO_ACTIVE=1 FAIL_START=1 bash "$script" "$state" "$work/bin/cutover"; then exit 1; fi
if grep -Fx rollback "$work/calls"; then exit 1; fi
test "$(jq -r .result "$state/activation-result.json")" = activated-service-failed
printf 'Espanso handoff: pause, safe recovery and resume failure passed.\n'
