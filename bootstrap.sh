#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${HOME}"
MANIFEST_DIR="${HOME}/.local/state/bootstrap/manifests"
PROFILES_DIR="${DOTFILES_DIR}/profiles"
CONFIG_ROOT="${DOTFILES_DIR}/config"

mkdir -p "$MANIFEST_DIR"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

usage() {
    cat <<EOF
bootstrap — Validated symlink farm for dotfiles

Usage:
  bootstrap use <category/module>       Deploy a single module
  bootstrap profile <name>              Deploy all modules from profiles/<name>.json
  bootstrap undo <category/module>      Rollback a module via manifest

Examples:
  bootstrap use app/fish
  bootstrap profile laptop
  bootstrap undo app/kitty
EOF
    exit 1
}

err()  { echo -e "${RED}error:${NC} $*" >&2; }
warn() { echo -e "${YELLOW}warn:${NC} $*" >&2; }
info() { echo -e "${CYAN}→${NC} $*"; }
ok()   { echo -e "  ${GREEN}✓${NC} $*"; }

confirm() {
    local prompt="$1"
    local ans
    read -rp "$prompt [s=skip / o=overwrite / b=backup]: " ans
    case "$ans" in
        s|S|skip) echo "skip" ;;
        o|O|overwrite) echo "overwrite" ;;
        b|B|backup) echo "backup" ;;
        *) echo "skip" ;;
    esac
}

normalize_module_ref() {
    local module_ref="${1:-}"
    module_ref="${module_ref#config/}"
    module_ref="${module_ref#/}"

    if [[ -z "$module_ref" ]] || [[ "$module_ref" != */* ]]; then
        err "Expected <category/module> (e.g. app/fish)"
        return 1
    fi

    printf '%s\n' "$module_ref"
}

module_source_dir() {
    local module_ref
    module_ref="$(normalize_module_ref "$1")" || return 1
    printf '%s\n' "${CONFIG_ROOT}/${module_ref}"
}

manifest_file() {
    local module_ref
    module_ref="$(normalize_module_ref "$1")" || return 1
    printf '%s\n' "${MANIFEST_DIR}/${module_ref//\//__}"
}

profile_modules() {
    local profile_path="$1"
    python3 - "$profile_path" <<'PY'
import json
import sys
from pathlib import Path

profile = Path(sys.argv[1])
data = json.loads(profile.read_text())
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
}

resolve_conflict() {
    local target="$1" source="$2"

    if [[ -L "$target" ]]; then
        local raw_link existing_real source_real
        raw_link="$(readlink "$target" 2>/dev/null || true)"
        existing_real="$(readlink -f "$target" 2>/dev/null || printf '%s' "$raw_link")"
        source_real="$(readlink -f "$source" 2>/dev/null || realpath "$source" 2>/dev/null || echo "$source")"

        if [[ "$existing_real" == "$source_real" ]]; then
            echo "skip"
            return
        fi

        case "$raw_link" in
            *Repos/dotfiles/app/*|*Repos/dotfiles/desktop/*|*Repos/dotfiles/misc/*|*Repos/dotfiles/system/*)
                warn "Stale dotfiles symlink at $target → $raw_link"
                echo "overwrite"
                return
                ;;
        esac

        warn "Symlink exists at $target → $existing_real"
        confirm "Replace with → $source ?"
        return
    fi

    if [[ -e "$target" ]]; then
        warn "File exists at $target (not a symlink)"
        confirm "How to handle?"
        return
    fi

    echo "create"
}

ensure_target_parent() {
    local target="$1"
    local parent
    parent="$(dirname "$target")"

    python3 - "$parent" <<'PY'
from pathlib import Path
import sys

parent = Path(sys.argv[1]).expanduser()
home = Path.home()

for path in reversed([parent, *parent.parents]):
    try:
        path.relative_to(home)
    except ValueError:
        continue

    if path.is_symlink() and not path.exists():
        path.unlink()

parent.mkdir(parents=True, exist_ok=True)
PY
}

symlink_module() {
    local module_ref src_dir mf
    module_ref="$(normalize_module_ref "$1")" || return 1
    src_dir="$(module_source_dir "$module_ref")" || return 1
    mf="$(manifest_file "$module_ref")" || return 1

    if [[ ! -d "$src_dir" ]]; then
        err "Source directory not found: $src_dir"
        return 1
    fi

    : > "$mf"
    info "Deploying ${module_ref}"

    local count=0
    while IFS= read -r -d '' src; do
        local rel="${src#"${src_dir}/"}"
        local target="${TARGET}/${rel}"

        local action
        action="$(resolve_conflict "$target" "$src")"

        case "$action" in
            skip)
                if [[ -L "$target" ]] && [[ "$(readlink "$target")" == "$src" ]]; then
                    ok "$rel (already linked)"
                else
                    warn "$rel (skipped)"
                fi
                ;;
            overwrite)
                rm -rf "$target"
                ;&
            create)
                ensure_target_parent "$target"
                ln -sf "$src" "$target"
                echo "$target" >> "$mf"
                ok "$rel"
                ((count++)) || true
                ;;
            backup)
                mv "$target" "${target}.bak"
                warn "$rel (backed up to ${target}.bak)"
                ensure_target_parent "$target"
                ln -sf "$src" "$target"
                echo "$target" >> "$mf"
                ((count++)) || true
                ;;
        esac
    done < <(find "$src_dir" -type f -print0)

    echo ""
    info "Linked $count files in ${module_ref}"
    return 0
}

validate_json_file() {
    local target="$1"
    python3 -m json.tool "$target" >/dev/null 2>&1 && ok "json valid: $(basename "$target")" || {
        err "json invalid: $target"
        return 1
    }
}

validate_module() {
    local module_ref mf
    module_ref="$(normalize_module_ref "$1")" || return 1
    mf="$(manifest_file "$module_ref")" || return 1
    local passed=0 failed=0

    if [[ ! -f "$mf" ]]; then
        info "No manifest for ${module_ref}, skipping validation"
        return 0
    fi

    while IFS= read -r target; do
        [[ -z "$target" ]] && continue

        if [[ ! -e "$target" ]]; then
            err "Broken symlink: $target"
            ((failed++)) || true
            continue
        fi

        local ext="${target##*.}"
        case "$ext" in
            fish)
                if command -v fish &>/dev/null; then
                    fish -n "$target" 2>/dev/null && ok "fish syntax: $(basename "$target")" || {
                        err "fish syntax: $target"
                        ((failed++)) || true
                    }
                fi
                ;;
            json)
                validate_json_file "$target" || ((failed++)) || true
                ;;
            kdl)
                ok "kdl: $(basename "$target")"
                ;;
            conf|cfg|toml|yml|yaml)
                ok "readable: $(basename "$target")"
                ;;
        esac

        if head -n1 "$target" 2>/dev/null | grep -q '^#!/'; then
            if [[ -x "$target" ]]; then
                ok "executable: $(basename "$target")"
            else
                warn "Missing executable bit: $target"
                chmod +x "$target" && ok "fixed: chmod +x $(basename "$target")"
            fi
        fi

        if [[ "$(basename "$target")" == "secrets.yaml" ]]; then
            if command -v sops &>/dev/null; then
                sops -d "$target" >/dev/null 2>&1 && ok "secrets decrypt: $(basename "$target")" || {
                    err "secrets decrypt failed: $target"
                    ((failed++)) || true
                }
            else
                warn "sops not found, skipping secrets check"
            fi
        fi

        ((passed++)) || true
    done < "$mf"

    echo ""
    if (( failed > 0 )); then
        err "Validation: $passed passed, $failed failed in ${module_ref}"
        return 1
    fi

    ok "Validation: $passed passed in ${module_ref}"
}

undo_module() {
    local module_ref mf
    module_ref="$(normalize_module_ref "$1")" || return 1
    mf="$(manifest_file "$module_ref")" || return 1

    if [[ ! -f "$mf" ]]; then
        warn "No manifest found for ${module_ref}"
        return 1
    fi

    info "Rolling back ${module_ref}"

    local count=0
    while IFS= read -r target; do
        [[ -z "$target" ]] && continue

        if [[ -L "$target" ]]; then
            rm "$target"
            ok "Removed: $target"
            ((count++)) || true
        else
            warn "Not a symlink, skipping: $target"
        fi
    done < "$mf"

    rm "$mf"
    echo ""
    info "Rolled back $count symlinks in ${module_ref}"
    return 0
}

deploy_profile() {
    local name="$1"
    local profile="${PROFILES_DIR}/${name}.json"

    if [[ ! -f "$profile" ]]; then
        err "Profile not found: $profile"
        return 1
    fi

    info "Deploying profile: $name"
    local failed=0

    while IFS= read -r module_ref; do
        [[ -z "$module_ref" ]] && continue
        symlink_module "$module_ref" && validate_module "$module_ref" || {
            ((failed++)) || true
            warn "$module_ref failed, continuing..."
        }
    done < <(profile_modules "$profile")

    if (( failed > 0 )); then
        err "Profile deploy finished with $failed failures"
        return 1
    fi

    ok "Profile deploy complete"
}

main() {
    local cmd="${1:-}"
    case "$cmd" in
        use)
            shift
            local module_ref="${1:-}"
            [[ -z "$module_ref" ]] && usage
            module_ref="$(normalize_module_ref "$module_ref")" || exit 1
            symlink_module "$module_ref" && validate_module "$module_ref"
            ;;
        profile)
            shift
            local name="${1:-}"
            [[ -z "$name" ]] && { err "Expected profile name"; usage; }
            deploy_profile "$name"
            ;;
        undo)
            shift
            local module_ref="${1:-}"
            [[ -z "$module_ref" ]] && usage
            module_ref="$(normalize_module_ref "$module_ref")" || exit 1
            undo_module "$module_ref"
            ;;
        *)
            usage
            ;;
    esac
}

main "$@"
