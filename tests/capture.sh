#!/usr/bin/env bash
# Exercise real capture scripts with deterministic compositor/Wayland fixtures.
set -euo pipefail
capture=$1
work=$(mktemp -d)
trap 'rm -rf -- "$work"' EXIT
export HOME="$work/home with spaces" TEST_WORK="$work"
mkdir -p "$HOME" "$work/bin" "$work/tmp"
export TMPDIR="$work/tmp"
export PATH="$work/bin:$PATH"
magick -size 40x20 xc:red "$work/image.png"
cat >"$work/bin/umbriel" <<'SH'
#!/bin/sh
case "$1" in
windows)
test "${FAIL_IPC:-0}" = 0 || exit 1
if [ "${WINDOWS+x}" = x ]; then printf '%s\n' "$WINDOWS"; else
printf '%s\n' '[{"id":"window-1","active":true,"focused":true,"app_id":"kitty","title":"terminal","x":-110.5,"y":20.25,"w":80.5,"h":40.5,"output":"DP-1"}]'
fi ;;
outputs) printf '%s\n' '[{"name":"DP-1","enabled":true,"focused":true,"scale":1.25,"position":{"x":-100,"y":0},"logical_size":{"width":100,"height":100}}]' ;;
*) exit 1 ;;
esac
SH
cat >"$work/bin/mmsg" <<'SH'
#!/bin/sh
if [ "$2" = all-monitors ]; then
  printf '%s\n' '{"monitors":[{"name":"DP-2","active":true,"x":-200,"y":0,"width":200,"height":100}]}'
else
  printf '%s\n' '{"id":7,"is_focused":true,"appid":"kitty","title":"terminal","x":-110.5,"y":20.25,"width":80.5,"height":40.5,"monitor":"DP-2"}'
fi
SH
cat >"$work/bin/capture-window" <<SH
#!/bin/sh
exec sh "$capture/window" "\$@"
SH
cat >"$work/bin/xdg-user-dir" <<'SH'
#!/bin/sh
printf '%s/%s files\n' "$HOME" "$1"
SH
cat >"$work/bin/slurp" <<'SH'
#!/bin/sh
printf '%s\n' "$@" > "$TEST_WORK/slurp-args"
test "${CANCEL:-0}" = 0 || exit 1
printf '%s\n' '-100,20 70x41'
SH
cat >"$work/bin/grim" <<'SH'
#!/bin/sh
test "${FAIL_GRIM:-0}" = 0 || exit 1
printf '%s\n' "$@" > "$TEST_WORK/grim-args"
for target do :; done
if [ "$target" = - ]; then cat "$TEST_WORK/image.png"; else cp "$TEST_WORK/image.png" "$target"; fi
SH
cat >"$work/bin/wl-copy" <<'SH'
#!/bin/sh
test "${FAIL_CLIPBOARD:-0}" = 0 || exit 1
printf '%s\n' "$@" > "$TEST_WORK/mime"
cat > "$TEST_WORK/clipboard"
SH
cat >"$work/bin/notify-send" <<'SH'
#!/bin/sh
test "${FAIL_NOTIFY:-0}" = 0 || exit 1
case "$*" in
*'Copied to clipboard'*) printf '%s' "${ACTION:-}" ;;
*'What do you want to do with it?'*) printf save ;;
esac
SH
cat >"$work/bin/satty" <<'SH'
#!/bin/sh
source=
for arg do
  if [ "$source" = next ]; then source=$arg; break; fi
  [ "$arg" != --filename ] || source=next
done
for target do :; done
cp "$source" "$target"
SH
cat >"$work/bin/tesseract" <<'SH'
#!/bin/sh
test "${FAIL_OCR:-0}" = 0 || exit 1
printf 'Hasil OCR Indonesia and English\n'
SH
cat >"$work/bin/ripdrag" <<'SH'
#!/bin/sh
for target do :; done
test -s "$target"
SH
chmod +x "$work/bin/"*
run_shot() { bash "$capture/shot" "$@" 2>&1 | cat; }
export XDG_CURRENT_DESKTOP=umbriel
test "$(capture-window geometry)" = '-100,20 70x41'
test "$(capture-window info)" = 'appid:kitty,title:terminal'
if WINDOWS='[]' capture-window geometry; then exit 1; fi
if FAIL_IPC=1 capture-window json; then exit 1; fi
# IPC failure in info must not be hidden by jq succeeding on empty input.
if FAIL_IPC=1 capture-window info >"$work/failed-info"; then exit 1; fi
test ! -s "$work/failed-info"
if WINDOWS='[]' capture-window info >"$work/failed-info"; then exit 1; fi
test ! -s "$work/failed-info"
if WINDOWS='' capture-window json; then exit 1; fi
export XDG_CURRENT_DESKTOP=mango
test "$(capture-window geometry)" = '-111,20 81x41'
# Both executables exist. The session, not PATH order, chooses its geometry.
for desktop in umbriel mango; do
	export XDG_CURRENT_DESKTOP=$desktop
	run_shot active
	test "$(magick identify -format '%wx%h' "$work/clipboard")" = 40x20
	grep -Fx image/png "$work/mime"
done
export XDG_CURRENT_DESKTOP=umbriel
for mode in screen output area; do run_shot "$mode"; done
cp "$work/clipboard" "$work/previous"
CANCEL=1 run_shot area
cmp "$work/previous" "$work/clipboard"
if FAIL_GRIM=1 run_shot screen; then exit 1; fi
cmp "$work/previous" "$work/clipboard"
if FAIL_CLIPBOARD=1 run_shot screen; then exit 1; fi
cmp "$work/previous" "$work/clipboard"
run_shot annotate
if grep -Ex -- '-o|-r' "$work/slurp-args"; then exit 1; fi
find "$HOME/PICTURES files/Screenshots" -name 'annotated-*.png' | while IFS= read -r file; do magick identify "$file"; done
run_shot ocr
grep -Fx text/plain "$work/mime"
grep -Fx 'Hasil OCR Indonesia and English' "$work/clipboard"
# Await the intentional background action notification with a bounded poll.
ACTION=save run_shot screen
for _ in $(seq 1 100); do
	if find "$HOME/PICTURES files/Screenshots" -name 'shot-*.png' | read -r _; then break; fi
	sleep 0.02
done
test "$(find "$HOME/PICTURES files/Screenshots" -name 'shot-*.png' | wc -l)" -ge 1
# Decoration must reach the second notification and publish the changed PNG.
ACTION=decorate run_shot screen
for _ in $(seq 1 100); do
	if [ "$(magick identify -format '%w' "$work/clipboard")" -gt 40 ]; then break; fi
	sleep 0.02
done
test "$(magick identify -format '%w' "$work/clipboard")" -gt 40
ACTION=drag run_shot screen
cp "$work/clipboard" "$work/previous"
if FAIL_OCR=1 run_shot ocr; then exit 1; fi
cmp "$work/previous" "$work/clipboard"
FAIL_NOTIFY=1 run_shot screen
cmp "$work/image.png" "$work/clipboard"
test "$(find "$work/tmp" -mindepth 1 | wc -l)" = 0
echo 'Capture: both backends, PNG, clipboard, actions, annotation, OCR and failure handling passed.'
