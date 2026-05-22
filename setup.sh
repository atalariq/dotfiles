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

    if ! command -v jq &>/dev/null; then
        echo "error: jq is required. Install it first." >&2
        exit 1
    fi

    local failed=0

    local apps
    apps="$(jq -r '.apps[]?' "$json_file" 2>/dev/null)" || true
    for app in $apps; do
        [[ -z "$app" ]] && continue
        "$BOOTSTRAP" use "app/$app" || ((failed++))
    done

    local desktop
    desktop="$(jq -r '.desktop[]?' "$json_file" 2>/dev/null)" || true
    for dm in $desktop; do
        [[ -z "$dm" ]] && continue
        "$BOOTSTRAP" use "desktop/$dm" || ((failed++))
    done

    local misc
    misc="$(jq -r '.misc[]?' "$json_file" 2>/dev/null)" || true
    for m in $misc; do
        [[ -z "$m" ]] && continue
        "$BOOTSTRAP" use "misc/$m" || ((failed++))
    done

    local sys
    sys="$(jq -r '.system // empty' "$json_file" 2>/dev/null)" || true
    if [[ -n "$sys" ]]; then
        "$BOOTSTRAP" use "system/$sys" || ((failed++))
    fi

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
