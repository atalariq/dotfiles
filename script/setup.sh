#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
BOOTSTRAP="${SCRIPT_DIR}/bootstrap.sh"

usage() {
	cat <<EOF
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
EOF
	exit 1
}

deploy_json_config() {
	local json_file="$1"

	if [[ ! -f "$json_file" ]]; then
		echo "error: JSON config not found: $json_file" >&2
		exit 1
	fi

	local failed=0

	while IFS= read -r module_ref; do
		[[ -z "$module_ref" ]] && continue
		"$BOOTSTRAP" use "$module_ref" || ((failed++))
	done < <(
		python3 - "$json_file" <<'PY'
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
	)

	if ((failed > 0)); then
		echo "Setup finished with $failed failures" >&2
		exit 1
	fi

	echo "Done!"
}

main() {
	# Collect flags to forward to bootstrap, leaving positional args intact
	local flags=()
	local pos_args=()
	local _a
	for _a in "$@"; do
		case "$_a" in
		--dry-run | --force) flags+=("$_a") ;;
		*) pos_args+=("$_a") ;;
		esac
	done

	local arg="${pos_args[0]:-}"

	if [[ -z "$arg" ]]; then
		usage
	fi

	# Short form: if the first non-flag arg contains '/' and is not a known
	# subcommand, treat it as: setup use <arg>
	case "$arg" in
	lab | personal | use | undo | restow | adopt | profile | secrets | *.json) ;;
	*)
		if [[ "$arg" == */* ]]; then
			pos_args=("use" "${pos_args[@]}")
			arg="use"
		fi
		;;
	esac

	case "$arg" in
	lab)
		"$BOOTSTRAP" "${flags[@]}" profile lab
		;;
	personal)
		"$BOOTSTRAP" "${flags[@]}" profile laptop
		;;
	use | undo | restow | adopt | profile | secrets)
		"$BOOTSTRAP" "${flags[@]}" "${pos_args[@]}"
		;;
	*.json)
		deploy_json_config "$arg"
		;;
	*)
		if [[ -f "${DOTFILES_DIR}/profiles/${arg}.json" ]]; then
			"$BOOTSTRAP" "${flags[@]}" profile "$arg"
		else
			usage
		fi
		;;
	esac
}

main "$@"
