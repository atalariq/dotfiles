#!/usr/bin/env bash
# Controller contracts at the IPC/systemd boundary; no owner session is touched.
set -euo pipefail
capture=${1:?capture source directory}
work=$(mktemp -d)
trap 'rm -rf -- "$work"' EXIT
export HOME="$work/home" XDG_RUNTIME_DIR="$work/runtime" TEST_WORK="$work"
export WAYLAND_DISPLAY=wayland-test XDG_CURRENT_DESKTOP=umbriel
mkdir -p "$HOME" "$XDG_RUNTIME_DIR" "$work/bin"
export PATH="$work/bin:$PATH"
printf window-1 >"$work/focus"
cat >"$work/bin/capture-window" <<'SH'
#!/bin/sh
case "$1" in
session) echo "${TEST_SESSION:-umbriel:test:1}" ;;
json) jq -nc --arg id "$(cat "$TEST_WORK/focus")" '{id: $id}' ;;
watch)
while :; do cat "$TEST_WORK/focus"; printf '\n'; sleep 0.01; done ;;
close) printf '%s\n' "$2" >>"$TEST_WORK/closed" ;;
output) echo DP-1 ;;
outputs) echo '[{"name":"DP-1","enabled":true,"focused":true,"scale":1.25,"position":{"x":-100,"y":0},"logical_size":{"width":100,"height":100}}]' ;;
*) exit 2 ;;
esac
SH
cat >"$work/bin/notify-send" <<'SH'
#!/bin/sh
printf '%s\n' "$*" >>"$TEST_WORK/notifications"
SH
cat >"$work/bin/systemctl" <<'SH'
#!/bin/sh
printf '%s\n' "$*" >>"$TEST_WORK/systemctl"
case "$2" in
is-active) test -f "$TEST_WORK/active" ;;
start) test "${START_FAIL:-0}" = 0 || exit 1; touch "$TEST_WORK/active" ;;
stop) rm -f "$TEST_WORK/active" ;;
show) if [ "${STOP_FAIL:-0}" = 0 ]; then echo success; else echo exit-code; fi ;;
reset-failed) : ;;
*) exit 2 ;;
esac
SH
cat >"$work/bin/pactl" <<'SH'
#!/bin/sh
case "$1" in
get-default-sink) echo test-output ;;
*) test "${NO_MONITOR:-0}" = 0 || { echo '[]'; exit 0; }
  echo '[{"name":"microphone","monitor_of_sink":null},{"name":"test-output.monitor","monitor_of_sink":0}]' ;;
esac
SH
cat >"$work/bin/slurp" <<'SH'
#!/bin/sh
test "${CANCEL:-0}" = 0 || exit 1
echo "${REGION:--99,1 71x41}"
SH
cat >"$work/bin/xdg-user-dir" <<'SH'
#!/bin/sh
echo "$HOME/Videos with spaces"
SH
cat >"$work/bin/ffprobe" <<'SH'
#!/bin/sh
test "${BAD_MP4:-0}" = 0 || exit 1
echo '{"streams":[{"codec_type":"video"}],"format":{"duration":"1.2"}}'
SH
cat >"$work/bin/gpu-screen-recorder" <<'SH'
#!/bin/sh
printf '%s\n' "$@" >"$TEST_WORK/worker-args"
printf '%s' "$WAYLAND_DISPLAY" >"$TEST_WORK/worker-display"
SH
cat >"$work/bin/hyprpicker" <<'SH'
#!/bin/sh
test "${CANCEL:-0}" = 0 || exit 1
echo "${COLOR:-#aBc123}"
SH
cat >"$work/bin/wl-copy" <<'SH'
#!/bin/sh
cat >"$TEST_WORK/clipboard"
SH
chmod +x "$work/bin/"*
record() { bash "$capture/record" "$@"; }
record area
request="$XDG_RUNTIME_DIR/dotfiles-record/request.json"
jq -e '.args as $a | ($a | index("-a")) as $i | $a[$i + 1] == "test-output.monitor"' "$request"
jq -e '.args | index("88x50") != null and index("71x41+-99+1") != null and index("h264") != null and index("60") != null' "$request"
if TEST_SESSION=changed record worker; then exit 1; fi
record worker
grep -Fx test-output.monitor "$work/worker-args"
test "$(cat "$work/worker-display")" = wayland-test
# An active recording stops even if the next selector would be cancelled.
CANCEL=1 record area
test ! -f "$work/active"
test "$(grep -c 'Recording saved' "$work/notifications")" = 1
CANCEL=1 record area
test ! -f "$work/active"
if REGION='-99,0 200x41' record area; then exit 1; fi
if NO_MONITOR=1 record toggle; then exit 1; fi
if START_FAIL=1 record toggle; then exit 1; fi
test ! -f "$work/active"
record toggle
if STOP_FAIL=1 record stop; then exit 1; fi
record toggle
if BAD_MP4=1 record stop; then exit 1; fi
test "$(grep -c 'Recording saved' "$work/notifications")" = 1
# Color cancellation/malformed output must preserve the previous clipboard.
bash "$capture/pick-color"
test "$(cat "$work/clipboard")" = '#aBc123'
CANCEL=1 bash "$capture/pick-color"
COLOR=invalid bash "$capture/pick-color"
test "$(cat "$work/clipboard")" = '#aBc123'
wait_ready() {
	for _ in $(seq 1 100); do
		[[ ! -f "$XDG_RUNTIME_DIR/dotfiles-close/ready" ]] || return 0
		sleep 0.005
	done
	echo 'Close watcher did not become ready' >&2
	exit 1
}
# Recover an abandoned request after the prior owner has died.
mkdir -p "$XDG_RUNTIME_DIR/dotfiles-close"
printf 'stale-session stale-id 99999999\n' >"$XDG_RUNTIME_DIR/dotfiles-close/armed"
# Timeout, changed focus, changed session and valid double press.
bash "$capture/close"
test ! -f "$work/closed"
bash "$capture/close" &
guard=$!
wait_ready
printf window-2 >"$work/focus"
sleep 0.06
printf window-1 >"$work/focus"
bash "$capture/close"
wait "$guard"
test ! -f "$work/closed"
bash "$capture/close" &
guard=$!
wait_ready
TEST_SESSION=another-session bash "$capture/close"
wait "$guard"
test ! -f "$work/closed"
bash "$capture/close" &
guard=$!
wait_ready
bash "$capture/close"
wait "$guard"
test "$(cat "$work/closed")" = window-1
# SIGKILL skips EXIT traps. Once the bounded watcher exits, ownership locks
# permit a fresh attempt rather than trusting an abandoned armed file.
bash "$capture/close" &
guard=$!
wait_ready
kill -KILL "$guard"
wait "$guard" 2>/dev/null || true
sleep 0.8
bash "$capture/close" &
guard=$!
wait_ready
bash "$capture/close"
wait "$guard"
test "$(wc -l <"$work/closed")" = 2
printf 'Desktop workflow: recording, finalization, system audio, color and close guard passed.\n'
