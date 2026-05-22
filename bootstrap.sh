#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${HOME}"
MANIFEST_DIR="${HOME}/.local/state/bootstrap/manifests"
PROFILES_DIR="${DOTFILES_DIR}/profiles"

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

# ─── helpers ─────────────────────────────────────────────────────────────────

err()  { echo -e "${RED}error:${NC} $*" >&2; }
warn() { echo -e "${YELLOW}warn:${NC} $*" >&2; }
info() { echo -e "${CYAN}→${NC} $*"; }
ok()   { echo -e "  ${GREEN}✓${NC} $*"; }

confirm() {
    local prompt="$1"
    local ans
    read -rp "$prompt [s=skip / o=overwrite / b=backup]: " ans
    case "$ans" in
        s|S|skip)   echo "skip"   ;;
        o|O|overwrite) echo "overwrite" ;;
        b|B|backup) echo "backup"  ;;
        *)          echo "skip"   ;;
    esac
}

manifest_file() {
    local category="$1" module="$2"
    echo "${MANIFEST_DIR}/${category}_${module}"
}

# ─── conflict resolution ─────────────────────────────────────────────────────

resolve_conflict() {
    local target="$1" source="$2"

    if [[ -L "$target" ]]; then
        local existing_real source_real
        existing_real="$(readlink -f "$target" 2>/dev/null || readlink "$target")"
        source_real="$(readlink -f "$source" 2>/dev/null || realpath "$source" 2>/dev/null || echo "$source")"
        if [[ "$existing_real" == "$source_real" ]]; then
            echo "skip"  # already linked to our source
            return
        fi
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

# ─── symlink deployment ──────────────────────────────────────────────────────

symlink_module() {
    local category="$1" module="$2"
    local src_dir="${DOTFILES_DIR}/${category}/${module}"
    local mf
    mf="$(manifest_file "$category" "$module")"

    if [[ ! -d "$src_dir" ]]; then
        err "Source directory not found: $src_dir"
        return 1
    fi

    info "Deploying ${category}/${module}"

    local count=0 errors=0
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
                mkdir -p "$(dirname "$target")"
                ln -sf "$src" "$target"
                echo "$target" >> "$mf"
                ok "$rel"
                ((count++)) || true
                ;;
            backup)
                mv "$target" "${target}.bak"
                warn "$rel (backed up to ${target}.bak)"
                mkdir -p "$(dirname "$target")"
                ln -sf "$src" "$target"
                echo "$target" >> "$mf"
                ((count++)) || true
                ;;
        esac
    done < <(find "$src_dir" -type f -print0)

    echo ""
    info "Linked $count files in ${category}/${module}"
    return 0
}

# ─── validation ──────────────────────────────────────────────────────────────

validate_module() {
    local category="$1" module="$2"
    local mf
    mf="$(manifest_file "$category" "$module")"
    local passed=0 failed=0

    if [[ ! -f "$mf" ]]; then
        info "No manifest for ${category}/${module}, skipping validation"
        return 0
    fi

    while IFS= read -r target; do
        [[ -z "$target" ]] && continue

        # symlink resolves
        if [[ ! -e "$target" ]]; then
            err "Broken symlink: $target"
            ((failed++)) || true
            continue
        fi

        # config syntax check by extension
        local ext="${target##*.}"
        case "$ext" in
            fish)
                if command -v fish &>/dev/null; then
                    fish -n "$target" 2>/dev/null && ok "fish syntax: $(basename "$target")" || { err "fish syntax: $target"; ((failed++)) || true; }
                fi
                ;;
            json)
                if command -v jq &>/dev/null; then
                    jq . "$target" >/dev/null 2>&1 && ok "json valid: $(basename "$target")" || { err "json invalid: $target"; ((failed++)) || true; }
                fi
                ;;
            kdl)
                ok "kdl: $(basename "$target")"
                ;;
            conf|cfg|conf|toml|yml|yaml)
                ok "readable: $(basename "$target")"
                ;;
        esac

        # script check: shebang + executable
        if head -c2 "$target" 2>/dev/null | grep -q '#!'; then
            local exec_bit
            if [[ -x "$target" ]]; then
                ok "executable: $(basename "$target")"
            else
                warn "Missing executable bit: $target"
                chmod +x "$target" && ok "fixed: chmod +x $(basename "$target")"
            fi
        fi

        # secrets check
        if [[ "$(basename "$target")" == "secrets.yaml" ]]; then
            if command -v sops &>/dev/null; then
                sops -d "$target" >/dev/null 2>&1 && ok "secrets decrypt: $(basename "$target")" || { err "secrets decrypt failed: $target"; ((failed++)) || true; }
            else
                warn "sops not found, skipping secrets check"
            fi
        fi

        ((passed++)) || true
    done < "$mf"

    echo ""
    if (( failed > 0 )); then
        err "Validation: $passed passed, $failed failed in ${category}/${module}"
        return 1
    else
        ok "Validation: $passed passed in ${category}/${module}"
    fi
}

# ─── undo / rollback ─────────────────────────────────────────────────────────

undo_module() {
    local category="$1" module="$2"
    local mf
    mf="$(manifest_file "$category" "$module")"

    if [[ ! -f "$mf" ]]; then
        warn "No manifest found for ${category}/${module}"
        return 1
    fi

    info "Rolling back ${category}/${module}"

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
    info "Rolled back $count symlinks in ${category}/${module}"
    return 0
}

# ─── profile deploy ──────────────────────────────────────────────────────────

deploy_profile() {
    local name="$1"
    local profile="${PROFILES_DIR}/${name}.json"

    if [[ ! -f "$profile" ]]; then
        err "Profile not found: $profile"
        return 1
    fi

    info "Deploying profile: $name"
    local failed=0

    # apps
    local apps
    apps="$(jq -r '.apps[]?' "$profile" 2>/dev/null)" || true
    for app in $apps; do
        [[ -z "$app" ]] && continue
        symlink_module "app" "$app" && validate_module "app" "$app" || { ((failed++)) || true; warn "app/$app failed, continuing..."; }
    done

    # desktop
    local desktop
    desktop="$(jq -r '.desktop[]?' "$profile" 2>/dev/null)" || true
    for dm in $desktop; do
        [[ -z "$dm" ]] && continue
        symlink_module "desktop" "$dm" && validate_module "desktop" "$dm" || { ((failed++)) || true; warn "desktop/$dm failed, continuing..."; }
    done

    # misc
    local misc
    misc="$(jq -r '.misc[]?' "$profile" 2>/dev/null)" || true
    for m in $misc; do
        [[ -z "$m" ]] && continue
        symlink_module "misc" "$m" && validate_module "misc" "$m" || { ((failed++)) || true; warn "misc/$m failed, continuing..."; }
    done

    # system
    local sys
    sys="$(jq -r '.system // empty' "$profile" 2>/dev/null)" || true
    if [[ -n "$sys" ]]; then
        symlink_module "system" "$sys" && validate_module "system" "$sys" || { ((failed++)) || true; warn "system/$sys failed, continuing..."; }
    fi

    if (( failed > 0 )); then
        err "Profile deploy finished with $failed failures"
        return 1
    fi
    ok "Profile deploy complete"
}

# ─── main ────────────────────────────────────────────────────────────────────

main() {
    local cmd="${1:-}"
    case "$cmd" in
        use)
            shift
            local arg="${1:-}"
            if [[ -z "$arg" ]] || [[ ! "$arg" =~ / ]]; then
                err "Expected <category/module> (e.g. app/fish)"
                usage
            fi
            local category="${arg%%/*}" module="${arg##*/}"
            symlink_module "$category" "$module" && validate_module "$category" "$module"
            ;;
        profile)
            shift
            local name="${1:-}"
            [[ -z "$name" ]] && { err "Expected profile name"; usage; }
            deploy_profile "$name"
            ;;
        undo)
            shift
            local arg="${1:-}"
            if [[ -z "$arg" ]] || [[ ! "$arg" =~ / ]]; then
                err "Expected <category/module> (e.g. app/fish)"
                usage
            fi
            local category="${arg%%/*}" module="${arg##*/}"
            undo_module "$category" "$module"
            ;;
        *)
            usage
            ;;
    esac
}

main "$@"
