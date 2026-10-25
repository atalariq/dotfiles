#!/usr/bin/env bash
set -euo pipefail
helper=$1
work=$(mktemp -d)
pid=
cleanup() {
	[[ -z $pid ]] || kill "$pid" 2>/dev/null || true
	rm -rf -- "$work"
}
trap cleanup EXIT
mkdir "$work/bin"
cat >"$work/bin/pluto" <<'SH'
#!/bin/sh
[ "${QUIT_FAIL:-0}" = 0 ] || exit 1
(sleep 0.3; printf flushed > "$FLUSHED"; kill -TERM "$TEST_PID") &
SH
chmod +x "$work/bin/pluto"
export PATH="$work/bin:$PATH" FLUSHED="$work/flushed"
sleep 20 &
pid=$!
export TEST_PID=$pid
sh "$helper" "$pid"
test "$(cat "$FLUSHED")" = flushed
wait "$pid" || true
pid=
sleep 20 &
pid=$!
export TEST_PID=$pid
if QUIT_FAIL=1 sh "$helper" "$pid"; then exit 1; fi
kill -0 "$pid"
kill "$pid"
wait "$pid" || true
pid=
printf 'Shelf stop: asynchronous quit waits for process exit; acknowledgement failure is reported.\n'
