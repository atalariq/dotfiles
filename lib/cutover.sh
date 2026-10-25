#!/usr/bin/env bash
# Owner-run, journalled HOME relocation. This command never invokes sudo/switch.
# shellcheck disable=SC2016 # jq programs intentionally contain literal $variables.
set -euo pipefail
umask 077
operation=${1:?Usage: dotfiles-cutover prepare HOST SYSTEM HOME_GENERATION [HOME] | status|relocate|rollback STATE}
shift
state=
fail() {
	printf '%s\n' "$*" >&2
	exit 1
}
same_filesystem() {
	local relative device
	device=$(stat -c %d -- "$state/relocated")
	while IFS= read -r -d '' relative; do
		[[ $(stat -c %d -- "$home/$relative") == "$device" ]] || fail "Cross-filesystem relocation refused: $relative"
	done <"$state/targets.nul"
}
identity() { stat -c '%d:%i:%f:%s' -- "$1"; }
json_write() {
	local destination=$1 temporary
	shift
	temporary=$(mktemp "$state/.json.XXXXXXXX")
	jq "$@" >"$temporary"
	mv -T -- "$temporary" "$destination"
	sync -f "$destination"
}
set_status() { json_write "$state/status.json" -n --arg status "$1" '{status:$status}'; }
load() {
	state=$(realpath -e -- "${1:?STATE required}")
	[[ -O $state && $(stat -c %a "$state") == 700 ]] || fail 'State must be owner-owned mode 0700.'
	# An owner handoff keeps this same open-file description locked through switch.
	# An independent process must acquire its own lock and cannot bypass it.
	if [[ ${DOTFILES_CUTOVER_LOCK_STATE:-} == "$state" && /proc/self/fd/9 -ef "$state/lock" ]]; then
		flock -n 9 || fail 'Inherited transaction lock is unavailable.'
	else
		exec 9>"$state/lock"
		flock -n 9 || fail 'Another cutover operation owns this state.'
	fi
	home=$(jq -er .home "$state/plan.json")
	generation=$(jq -er .generation "$state/plan.json")
	[[ $(jq -r .owner "$state/plan.json") == "$(id -un)" ]] || fail 'Cutover owner mismatch.'
	(
		cd "$state"
		sha256sum -c SHA256SUMS >&2
	) || fail 'Backup checksum mismatch.'
}
known_new_link() {
	local path=$1 relative=$2 link
	[[ -L $path ]] || return 1
	link=$(readlink -- "$path") || return 1
	[[ $link == "$generation/home-files/$relative" || $link == "$(readlink -f "$generation/home-files")/$relative" ]]
}
known_new_target() {
	local path=$1 relative=$2 leaf suffix
	if [[ -L $path ]]; then
		known_new_link "$path" "$relative"
		return
	fi
	[[ -d $path ]] || return 1
	# Never move an unknown user file out of the way during rollback.
	find "$path" \( -type f -o -type l -o \( ! -type d ! -type f ! -type l \) \) -print0 >"$state/rollback-scan" || return 1
	while IFS= read -r -d '' leaf; do
		suffix=${leaf#"$path"/}
		known_new_link "$leaf" "$relative/$suffix" || return 1
	done <"$state/rollback-scan"
}
rollback() {
	local journal relative original saved found=0
	set_status rolling-back
	find "$state/journal" -name '*.json' -print0 >"$state/journal-list"
	sort -zr "$state/journal-list" >"$state/journal-reverse"
	while IFS= read -r -d '' journal; do
		found=1
		relative=$(jq -er .relative "$journal")
		original=$home/$relative saved=$state/relocated/$relative
		if [[ -e $saved || -L $saved ]]; then
			[[ $(identity "$saved") == "$(jq -r .identity "$journal")" ]] || fail "Relocated identity changed: $relative"
			tar -C "$state/relocated" --compare -f "$state/home-links.tar" -- "$relative" >"$state/rollback-compare.log" 2>&1 || fail "Relocated contents changed: $relative"
			if [[ -e $original || -L $original ]]; then
				known_new_target "$original" "$relative" || {
					set_status rollback-blocked
					fail "Unknown HOME target; preserved both copies: $relative"
				}
				mkdir -p -- "$(dirname -- "$state/installed/$relative")"
				mv --no-copy -T --update=none-fail -- "$original" "$state/installed/$relative"
			fi
			mkdir -p -- "$(dirname -- "$original")"
			mv --no-copy -T --update=none-fail -- "$saved" "$original"
		else
			[[ -e $original || -L $original ]] || fail "Neither original nor relocated target exists: $relative"
			[[ $(identity "$original") == "$(jq -r .identity "$journal")" ]] || fail "Original identity changed: $relative"
		fi
		json_write "$journal" '.status="restored"' "$journal"
	done <"$state/journal-reverse"
	if ((found)); then set_status restored; else set_status prepared; fi
}
case "$operation" in
prepare)
	host=${1:?HOST required} system=${2:?SYSTEM required} generation=${3:?HOME_GENERATION required}
	home=$(realpath -e -- "${4:-$HOME}")
	[[ $host != *[!a-zA-Z0-9_-]* && -n $host ]] || fail 'Invalid host name.'
	[[ -x $system/bin/switch-to-configuration && -d $generation/home-files ]] || fail 'Build system and Home Manager outputs first.'
	source=$(nix flake metadata --json --no-write-lock-file | jq -er .path)
	[[ $(nix eval --raw "path:$source#nixosConfigurations.$host.config.system.build.toplevel.outPath") == "$system" ]] || fail 'System differs from the immutable source snapshot.'
	owner=$(id -un)
	[[ $(nix eval --raw "path:$source#lib.hostRegistry.$host.username") == "$owner" ]] || fail 'Host identity differs from this owner.'
	[[ $(nix eval --raw "path:$source#nixosConfigurations.$host.config.home-manager.users.$owner.home.activationPackage.outPath") == "$generation" ]] || fail 'Home generation differs from the immutable source snapshot.'
	parent=${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/cutover
	mkdir -p "$parent"
	state=$(mktemp -d "$parent/transaction.XXXXXXXX")
	printf 'Preparing private cutover state: %s\n' "$state" >&2
	exec 9>"$state/lock"
	flock 9
	mkdir "$state/roots" "$state/journal" "$state/relocated" "$state/installed"
	set_status preparing
	dotfiles-audit-home "$generation" "$home" >"$state/audit.tsv"
	jq -Rn --arg home "$home/" '
    [inputs | split("\t") | select(.[0] != "absent" and .[0] != "managed-link" and .[0] != "identical") |
      {relative:(.[1] | ltrimstr($home)),kind:.[0]}] | unique_by(.relative) | sort_by(.relative) |
    reduce .[] as $entry ([]; if any(.[]; .relative as $parent | $entry.relative | startswith($parent + "/")) then . else . + [$entry] end)
  ' <"$state/audit.tsv" >"$state/entries.json"
	# A path in a manifest is always relative and cannot escape HOME.
	jq -e 'all(.[]; .relative != "" and (.relative|startswith("/")|not) and ([.relative|split("/")[]] | all(. != ".." and . != ".")))' "$state/entries.json" >/dev/null || fail 'Unsafe audit path.'
	jq -jr '.[] | .relative,"\u0000"' "$state/entries.json" >"$state/targets.nul"
	while IFS= read -r -d '' relative; do
		[[ ! -e $home/$relative ]] || printf '%s\0' "$relative"
	done <"$state/targets.nul" >"$state/effective-targets.nul"
	same_filesystem
	tar -C "$home" --null --verbatim-files-from -cpf "$state/home-links.tar" -T "$state/targets.nul"
	tar -C "$home" --dereference --null --verbatim-files-from -cpf "$state/home-contents.tar" -T "$state/effective-targets.nul"
	tar -C "$home" --compare -f "$state/home-links.tar"
	tar -C "$home" --dereference --compare -f "$state/home-contents.tar"
	for name in reviewed-system reviewed-home reviewed-source recovery-running recovery-booted recovery-profile; do
		case "$name" in
		reviewed-system) target=$system ;;
		reviewed-home) target=$generation ;;
		reviewed-source) target=$source ;;
		recovery-running) target=$(readlink -f /run/current-system) ;;
		recovery-booted) target=$(readlink -f /run/booted-system) ;;
		recovery-profile) target=$(readlink -f /nix/var/nix/profiles/system) ;;
		esac
		[[ -d $target ]] || fail "Missing retention target: $name"
		nix-store --realise "$target" --add-root "$state/roots/$name" --indirect >/dev/null
	done
	jq -n --arg home "$home" --arg generation "$generation" --arg system "$system" --arg source "$source" --arg host "$host" --arg owner "$owner" \
		'{home:$home,generation:$generation,system:$system,source:$source,host:$host,owner:$owner}' >"$state/plan.json"
	while IFS= read -r -d '' relative; do
		fingerprint=$(identity "$home/$relative")
		jq -n --arg relative "$relative" --arg identity "$fingerprint" '{relative:$relative,identity:$identity}'
	done <"$state/targets.nul" | jq -s . >"$state/identities.json"
	(
		cd "$state"
		sha256sum home-links.tar home-contents.tar plan.json identities.json targets.nul effective-targets.nul audit.tsv entries.json >SHA256SUMS
	)
	chmod 600 "$state/"*.json "$state/"*.tsv "$state/"*.tar "$state/"*.nul "$state/SHA256SUMS"
	set_status prepared
	printf '%s\n' "$state"
	;;
status)
	load "${1:?STATE required}"
	jq -r '.status' "$state/status.json"
	jq '{home,system,generation,host,source}' "$state/plan.json"
	printf 'Owner activation command after successful relocation:\n'
	printf 'sudo nixos-rebuild switch --flake %q\n' "path:$(jq -r .source "$state/plan.json")#$(jq -r .host "$state/plan.json")"
	;;
relocate)
	load "${1:?STATE required}"
	[[ $(jq -r .status "$state/status.json") == prepared ]] || fail 'State is not prepared; inspect/rollback the existing journal.'
	dotfiles-audit-home "$generation" "$home" >"$state/current-audit.tsv"
	cmp "$state/audit.tsv" "$state/current-audit.tsv" || fail 'HOME inventory changed since preparation.'
	tar -C "$home" --compare -f "$state/home-links.tar" || fail 'Original HOME entries changed.'
	tar -C "$home" --dereference --compare -f "$state/home-contents.tar" || fail 'Effective configuration changed.'
	same_filesystem
	set_status relocating
	# An ordinary failure rolls back completed moves; SIGKILL is recoverable from intent records.
	finish_relocation() {
		local code=$?
		trap - EXIT
		if ((code != 0)); then rollback; fi
		exit "$code"
	}
	trap finish_relocation EXIT
	index=0
	while IFS= read -r -d '' relative; do
		fingerprint=$(jq -er --arg relative "$relative" '.[]|select(.relative==$relative)|.identity' "$state/identities.json")
		[[ $(identity "$home/$relative") == "$fingerprint" ]] || fail "Target changed before relocation: $relative"
		printf -v journal '%s/journal/%06d.json' "$state" "$index"
		json_write "$journal" -n --arg relative "$relative" --arg identity "$fingerprint" '{relative:$relative,identity:$identity,status:"intent"}'
		mkdir -p -- "$(dirname -- "$state/relocated/$relative")"
		mv --no-copy -T --update=none-fail -- "$home/$relative" "$state/relocated/$relative"
		json_write "$journal" '.status="moved"' "$journal"
		index=$((index + 1))
	done <"$state/targets.nul"
	set_status relocated
	trap - EXIT
	printf 'Relocated %s entries. Run status to inspect the immutable activation target.\n' "$index"
	;;
rollback)
	load "${1:?STATE required}"
	rollback
	;;
*) fail 'Usage: dotfiles-cutover prepare HOST SYSTEM HOME_GENERATION [HOME] | status|relocate|rollback STATE' ;;
esac
