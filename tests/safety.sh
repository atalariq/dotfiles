#!/usr/bin/env bash
# shellcheck disable=SC2016
set -euo pipefail
audit=$1
function_file=$2
work=$(mktemp -d)
trap 'chmod -R u+rwx "$work"; rm -rf -- "$work"' EXIT
mkdir -p "$work/generation/home-files/.config" "$work/home/.config" "$work/bin"
printf declared >"$work/generation/home-files/.config/fixture"
printf owner >"$work/home/.config/fixture"
sh "$audit" "$work/generation" "$work/home" >"$work/inventory"
grep -F $'conflict\t' "$work/inventory"
# A special file must be classified without opening it for comparison.
rm "$work/home/.config/fixture"
mkfifo "$work/home/.config/fixture"
timeout 5 sh "$audit" "$work/generation" "$work/home" >"$work/inventory"
grep -F $'conflict\t' "$work/inventory"
rm "$work/home/.config/fixture"
printf owner >"$work/home/.config/fixture"
cat >"$work/bin/find" <<'SH'
#!/bin/sh
printf 'partial unsafe inventory\n'
echo 'simulated traversal failure' >&2
exit 1
SH
chmod +x "$work/bin/find"
if PATH="$work/bin:$PATH" sh "$audit" "$work/generation" "$work/home" >"$work/failed"; then exit 1; fi
test ! -s "$work/failed"
# Real denied traversal is meaningful when the test user is not root.
if [[ $(id -u) != 0 ]]; then
	chmod 000 "$work/generation/home-files"
	if sh "$audit" "$work/generation" "$work/home" >"$work/failed"; then exit 1; fi
	test ! -s "$work/failed"
	chmod 700 "$work/generation/home-files"
fi
cat >"$work/bin/curl" <<'SH'
#!/bin/sh
printf '%s\n' "$@" > "$REQUEST_LOG"
if [ "${CURL_FAIL:-0}" = 1 ]; then printf partial; exit 22; fi
printf 'generated rules\n'
SH
chmod +x "$work/bin/curl"
rm -f "$work/bin/find"
export PATH="$work/bin:$PATH" REQUEST_LOG="$work/request"
cd "$work/home"
printf original >.gitignore
chmod 640 .gitignore
if CURL_FAIL=1 fish --no-config -c 'source $argv[1]; gignore linux' -- "$function_file"; then exit 1; fi
test "$(cat .gitignore)" = original
test "$(stat -c %a .gitignore)" = 640
fish --no-config -c 'source $argv[1]; gignore linux node' -- "$function_file"
grep -Fx 'generated rules' .gitignore
grep -Fx 'https://www.toptal.com/developers/gitignore/api/linux,node' "$REQUEST_LOG"
test "$(stat -c %a .gitignore)" = 640
mv .gitignore owner-rules
ln -s owner-rules .gitignore
if fish --no-config -c 'source $argv[1]; gignore linux' -- "$function_file"; then exit 1; fi
test -L .gitignore
test "$(find . -name '.gitignore.tmp.*' | wc -l)" = 0
