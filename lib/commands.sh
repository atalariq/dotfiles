#!/bin/sh
# The registry owns identity/platform; nh owns build and activation semantics.
set -eu
operation=${1:?operation required}
host=${2:?host required}
case "$operation" in build | build-fast | diff | apply) : ;; *)
	echo 'Unknown operation' >&2
	exit 2
	;;
esac
case "$host" in '' | *[!a-zA-Z0-9_-]*)
	echo 'Invalid host name' >&2
	exit 2
	;;
esac
host_data=$(nix eval --json ".#lib.hostRegistry.$host" --apply 'h: { inherit (h) kind system username; }')
kind=$(printf '%s' "$host_data" | jq -r .kind)
system=$(printf '%s' "$host_data" | jq -r .system)
case "$kind" in
nixos | wsl)
	family=os
	selector=--hostname
	;;
darwin)
	family=darwin
	selector=--hostname
	;;
home)
	family=home
	selector=--configuration
	;;
*)
	echo 'Unsupported host kind' >&2
	exit 2
	;;
esac
if [ "$operation" = apply ]; then
	current_system=$(nix eval --impure --raw --expr builtins.currentSystem)
	[ "$current_system" = "$system" ] || {
		echo 'Host architecture/OS does not match this machine' >&2
		exit 2
	}
	if [ "$kind" = nixos ] || [ "$kind" = wsl ]; then
		[ -e /etc/NIXOS ] || {
			echo 'System apply requires NixOS; use a Home Manager host here' >&2
			exit 2
		}
	fi
	if [ "$kind" = wsl ]; then
		grep -qi microsoft /proc/sys/kernel/osrelease || {
			echo 'WSL target requires WSL' >&2
			exit 2
		}
	fi
	owner=$(printf '%s' "$host_data" | jq -r .username)
	[ "$(id -un)" = "$owner" ] || {
		echo 'Adapt the example identity before applying' >&2
		exit 2
	}
	exec nh "$family" switch . "$selector" "$host"
fi
if [ "$operation" = build-fast ]; then
	if command -v dotfiles-boost >/dev/null 2>&1; then
		exec dotfiles-boost nh "$family" build . "$selector" "$host" --max-jobs 1 --cores 8
	fi
	exec nh "$family" build . "$selector" "$host" --max-jobs 1 --cores 8
fi
if [ "$operation" = diff ]; then
	exec nh "$family" build . "$selector" "$host" --diff always
fi
exec nh "$family" build . "$selector" "$host"
