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
espanso_paused=false
relocation_attempted=false
relocated=false
finish() {
	local code=$?
	trap - EXIT
	if ((code != 0)); then
		# Diagnostic writes must never prevent the external journalled rollback.
		set +e
		printf 'Activation failed (%s); restoring HOME. System rollback is separate.\n' "$code" >&2
		jq -n --argjson code "$code" '{result:"failed",exitCode:$code}' >"$state/activation-result.json"
		local safe_to_resume=true
		if [[ $relocated == true ]]; then
			if ! "$cutover" rollback "$state"; then
				safe_to_resume=false
				printf 'HOME rollback incomplete; preserve both copies and inspect the journal.\n' >&2
			fi
		elif [[ $relocation_attempted == true ]]; then
			case $(jq -r .status "$state/status.json") in
			prepared | restored) ;;
			*) safe_to_resume=false ;;
			esac
		fi
		if [[ $espanso_paused == true && $safe_to_resume == true ]]; then
			systemctl --user start espanso.service || printf 'Could not resume Espanso after recovery.\n' >&2
		fi
	fi
	exit "$code"
}
trap finish EXIT
# The daemon recreates match/packages while its configuration is relocated.
# Pause only an already-active instance; leave an inactive instance inactive.
if [[ -e $generation/home-files/.config/espanso/match ]] && systemctl --user is-active --quiet espanso.service; then
	espanso_paused=true
	systemctl --user stop espanso.service
fi
relocation_attempted=true
"$cutover" relocate "$state"
relocated=true
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
# Core migration is now verified; restarting a utility must not roll it back.
trap - EXIT
if [[ $espanso_paused == true ]] && ! systemctl --user start espanso.service; then
	jq -n '{result:"activated-service-failed",service:"espanso.service"}' >"$state/activation-result.json"
	echo 'System and HOME activated, but Espanso could not resume; inspect its user journal.' >&2
	exit 1
fi
jq -n --arg system "$system" --arg source "$source" --arg at "$(date -u +%FT%TZ)" \
	'{result:"activated",system:$system,source:$source,at:$at}' >"$state/activation-result.json"
trap - EXIT
printf 'System and Home Manager activation verified. Keep backups until desktop acceptance.\n'
