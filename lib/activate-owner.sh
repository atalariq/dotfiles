#!/usr/bin/env bash
# Owner-terminal handoff: authenticate before touching HOME, then verify activation.
set -euo pipefail
umask 077
state=$(realpath -e -- "${1:?Usage: activate-owner.sh STATE CUTOVER_COMMAND}")
cutover=${2:?CUTOVER_COMMAND required}
[[ -O $state && $(stat -c %a "$state") == 700 ]] || {
	echo 'State must be owner-owned mode 0700.' >&2
	exit 1
}
exec 9>"$state/lock"
flock -n 9 || {
	echo 'Another cutover operation owns this state.' >&2
	exit 1
}
export DOTFILES_CUTOVER_LOCK_STATE=$state
"$cutover" status "$state"
[[ $(jq -r .status "$state/status.json") == prepared ]] || {
	echo 'Transaction must be prepared; inspect its journal before retrying.' >&2
	exit 1
}
source=$(jq -er .source "$state/plan.json")
host=$(jq -er .host "$state/plan.json")
owner=$(jq -er .owner "$state/plan.json")
system=$(jq -er .system "$state/plan.json")
generation=$(jq -er .generation "$state/plan.json")
[[ $owner == "$(id -un)" ]] || exit 1
if [[ -f $state/protected-codex.sha256 ]]; then sha256sum -c "$state/protected-codex.sha256"; fi
# Password prompts stay in the owner's terminal, before any HOME relocation.
sudo -v
"$cutover" relocate "$state"
finish() {
	local code=$?
	trap - EXIT
	if ((code != 0)); then
		# Diagnostic writes must never prevent the external journalled rollback.
		set +e
		printf 'Activation failed (%s); restoring HOME. System rollback is separate.\n' "$code" >&2
		jq -n --argjson code "$code" '{result:"failed",exitCode:$code}' >"$state/activation-result.json"
		if ! "$cutover" rollback "$state"; then
			printf 'HOME rollback incomplete; preserve both copies and inspect the journal.\n' >&2
		fi
	fi
	exit "$code"
}
trap finish EXIT
# Never pause for a password after HOME has moved; expiry triggers rollback.
sudo -n nixos-rebuild switch --flake "path:$source#$host" 2>&1 | tee "$state/owner-switch.log"
[[ $(systemctl show "home-manager-$owner.service" -p Result --value) == success ]]
[[ $(systemctl show "home-manager-$owner.service" -p ExecMainStatus --value) == 0 ]]
[[ $(readlink -f /run/current-system) == "$system" ]]
[[ $(readlink -f /nix/var/nix/profiles/system) == "$system" ]]
active_home=$(readlink -f "${XDG_STATE_HOME:-$HOME/.local/state}/home-manager/gcroots/current-home")
matched=false
for candidate in "$generation" "$generation"/specialisation/*; do
	if [[ $(readlink -f "$candidate") == "$active_home" ]]; then
		matched=true
		break
	fi
done
[[ $matched == true ]]
if [[ -f $state/protected-codex.sha256 ]]; then sha256sum -c "$state/protected-codex.sha256"; fi
jq -n --arg system "$system" --arg source "$source" --arg at "$(date -u +%FT%TZ)" \
	'{result:"activated",system:$system,source:$source,at:$at}' >"$state/activation-result.json"
trap - EXIT
printf 'System and Home Manager activation verified. Keep backups until desktop acceptance.\n'
