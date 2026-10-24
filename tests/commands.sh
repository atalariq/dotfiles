#!/usr/bin/env bash
# Exercise the public command routing without ever building/applying/cleaning a host.
set -euo pipefail
root=$1
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/bin"
export ROUTE_LOG="$work/calls"
cat >"$work/bin/nix" <<'MOCK'
#!/bin/sh
case "$*" in
  *builtins.currentSystem*) echo x86_64-linux;;
  *macos*) echo '{"kind":"darwin","system":"aarch64-darwin","username":"example"}';;
  *ubuntu*) echo '{"kind":"home","system":"x86_64-linux","username":"example"}';;
  *) echo '{"kind":"nixos","system":"x86_64-linux","username":"example"}';;
esac
MOCK
cat >"$work/bin/nh" <<'MOCK'
#!/bin/sh
printf '%s\n' "$@" > "$ROUTE_LOG"
MOCK
chmod +x "$work/bin/"*
export PATH="$work/bin:$PATH"
sh "$root/lib/commands.sh" build ubuntu-x86_64-linux
grep -Fx 'home' "$ROUTE_LOG"
grep -Fx -- '--configuration' "$ROUTE_LOG"
sh "$root/lib/commands.sh" diff thinkpad-x13
grep -Fx 'thinkpad-x13' "$ROUTE_LOG"
grep -Fx -- '--diff' "$ROUTE_LOG"
rm "$ROUTE_LOG"
if sh "$root/lib/commands.sh" apply macos-example; then
	echo 'Foreign-platform apply accepted' >&2
	exit 1
fi
test ! -e "$ROUTE_LOG"
if sh "$root/lib/commands.sh" build 'ubuntu;echo injected'; then
	echo 'Invalid target accepted' >&2
	exit 1
fi
test ! -e "$ROUTE_LOG"
if sh "$root/lib/commands.sh" apply ubuntu-x86_64-linux; then
	echo 'Example identity accepted' >&2
	exit 1
fi
test ! -e "$ROUTE_LOG"
echo 'Command routing and apply preflight passed.'
