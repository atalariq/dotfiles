#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOOTSTRAP="${SCRIPT_DIR}/bootstrap.sh"

usage() {
    cat <<EOF
setup — dotfiles deployment wrapper

Usage:
  setup lab                            Deploy lab profile
  setup personal                       Deploy laptop profile
  setup <profile-name>                 Deploy profiles/<name>.json
  setup use <category/module>          Deploy a single module directly
  setup undo <category/module>         Rollback a single module
  setup <path/to/config.json>          Deploy from a custom JSON config

Examples:
  setup lab
  setup personal
  setup use app/fish
  setup undo app/kitty
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
    done < <(python3 - "$json_file" <<'PY'
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

    if (( failed > 0 )); then
        echo "Setup finished with $failed failures" >&2
        exit 1
    fi

    echo "Done!"
}

main() {
    local arg="${1:-}"

    if [[ -z "$arg" ]]; then
        usage
    fi

    case "$arg" in
        lab)
            "$BOOTSTRAP" profile lab
            ;;
        personal)
            "$BOOTSTRAP" profile laptop
            ;;
        use|undo|profile)
            "$BOOTSTRAP" "$@"
            ;;
        *.json)
            deploy_json_config "$arg"
            ;;
        *)
            if [[ -f "${SCRIPT_DIR}/profiles/${arg}.json" ]]; then
                "$BOOTSTRAP" profile "$arg"
            else
                usage
            fi
            ;;
    esac
}

main "$@"
