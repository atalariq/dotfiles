#!/bin/sh
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
DOTFILES_DIR="$(CDPATH= cd -- "${SCRIPT_DIR}/.." && pwd)"
BOOTSTRAP="${SCRIPT_DIR}/bootstrap.sh"

usage() {
	cat <<'EOF'
setup — dotfiles deployment wrapper

Usage:
  setup [--dry-run] [--force] lab                    Deploy lab profile
  setup [--dry-run] [--force] personal               Deploy laptop profile
  setup [--dry-run] [--force] <profile-name>         Deploy profiles/<name>.json
  setup [--dry-run] [--force] use <category/module>  Deploy a single module directly
  setup [--dry-run] [--force] undo <category/module> Rollback a single module
  setup [--dry-run] [--force] undo profile <name>    Rollback a full profile
  setup [--dry-run] [--force] restow <category/module> Re-deploy a module
  setup [--dry-run]           adopt <category/module>   Adopt existing HOME files
  setup [--dry-run]           secrets                Link secrets files
  setup <path/to/config.json>                        Deploy from a custom JSON config
  setup                       doctor                 Check all deployed symlinks for breakage
  setup                       status [category/module] Show deployment status
  setup                       diff   [category/module] Show symlink drift

  Short form: setup app/fish  (equivalent to: setup use app/fish)

Options:
  --dry-run   Print actions without executing them
  --force     Skip interactive prompts (always overwrite)

Examples:
  setup lab
  setup personal
  setup use app/fish
  setup app/fish
  setup undo app/kitty
  setup undo profile laptop
  setup restow app/nvim
  setup secrets
  setup doctor
  setup status app/fish
  setup diff
EOF
	exit 1
}

deploy_json_config() {
	json_file="$1"

	if [ ! -f "$json_file" ]; then
		echo "error: JSON config not found: $json_file" >&2
		exit 1
	fi

	failed=0

	for module_ref in $(python3 - "$json_file" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
data = json.loads(path.read_text())
modules = data.get("modules")
if isinstance(modules, list):
    for module in modules:
        if isinstance(module, str) and module.strip():
            print(module.strip())
    raise SystemExit(0)

for module in data.get("apps", []):
    print(f"app/{module}")
for module in data.get("desktop", []):
    print(f"desktop/{module}")
for module in data.get("misc", []):
    print(f"misc/{module}")
system = data.get("system")
if isinstance(system, str) and system.strip():
    print(f"system/{system.strip()}")
PY
	); do
		[ -z "$module_ref" ] && continue
		if [ -n "$FLAGS" ]; then
			"$BOOTSTRAP" $FLAGS use "$module_ref" || failed=$((failed + 1))
		else
			"$BOOTSTRAP" use "$module_ref" || failed=$((failed + 1))
		fi
	done

	if [ "$failed" -gt 0 ]; then
		echo "Setup finished with $failed failures" >&2
		exit 1
	fi

	echo "Done!"
}

main() {
	FLAGS=""
	has_pos=""

	# Filter flags and collect positional arguments
	for a in "$@"; do
		case "$a" in
		--dry-run | --force)
			FLAGS="${FLAGS}${FLAGS:+ }$a"
			;;
		*)
			if [ -z "$has_pos" ]; then
				set -- "$a"
				has_pos="1"
			else
				set -- "$@" "$a"
			fi
			;;
		esac
	done

	if [ -z "$has_pos" ]; then
		usage
	fi

	arg="$1"

	# Short form: if the first non-flag arg contains '/' and is not a known
	# subcommand, treat it as: setup use <arg>
	case "$arg" in
	lab | personal | use | undo | restow | adopt | profile | secrets | doctor | status | diff | *.json) ;;
	*/*)
		set -- "use" "$@"
		arg="use"
		;;
	esac

	case "$arg" in
	lab)
		if [ -n "$FLAGS" ]; then
			"$BOOTSTRAP" $FLAGS profile lab
		else
			"$BOOTSTRAP" profile lab
		fi
		;;
	personal)
		if [ -n "$FLAGS" ]; then
			"$BOOTSTRAP" $FLAGS profile laptop
		else
			"$BOOTSTRAP" profile laptop
		fi
		;;
	use | undo | restow | adopt | profile | secrets | doctor | status | diff)
		if [ -n "$FLAGS" ]; then
			"$BOOTSTRAP" $FLAGS "$@"
		else
			"$BOOTSTRAP" "$@"
		fi
		;;
	*.json)
		deploy_json_config "$arg"
		;;
	*)
		if [ -f "${DOTFILES_DIR}/profiles/${arg}.json" ] || [ -f "${DOTFILES_DIR}/profiles/${arg}.local.json" ]; then
			if [ -n "$FLAGS" ]; then
				"$BOOTSTRAP" $FLAGS profile "$arg"
			else
				"$BOOTSTRAP" profile "$arg"
			fi
		else
			usage
		fi
		;;
	esac
}

main "$@"

