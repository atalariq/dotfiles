#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="${HOME}"
MANIFEST_DIR="${HOME}/.local/state/bootstrap/manifests"
PROFILES_DIR="${DOTFILES_DIR}/profiles"
CONFIG_ROOT="${DOTFILES_DIR}/config"
SECRETS_DIR="${DOTFILES_DIR}/secrets"

mkdir -p "$MANIFEST_DIR"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# ---------------------------------------------------------------------------
# Global flags — stripped before dispatch
# ---------------------------------------------------------------------------
DRY_RUN=0
FORCE=0

_args=()
for _a in "$@"; do
	case "$_a" in
	--dry-run) DRY_RUN=1 ;;
	--force) FORCE=1 ;;
	*) _args+=("$_a") ;;
	esac
done
set -- "${_args[@]}"
unset _a _args

usage() {
	cat <<EOF
bootstrap — Validated symlink farm for dotfiles

Usage:
  bootstrap [--dry-run] [--force] use <category/module>
  bootstrap [--dry-run] [--force] profile <name>
  bootstrap [--dry-run] [--force] restow <category/module>
  bootstrap [--dry-run]           adopt <category/module>
  bootstrap [--dry-run] [--force] undo <category/module>
  bootstrap [--dry-run] [--force] undo profile <name>
  bootstrap [--dry-run]           secrets
  bootstrap                       doctor
  bootstrap                       status [category/module]
  bootstrap                       diff   [category/module]

Options:
  --dry-run   Print actions without executing them
  --force     Skip interactive prompts (always overwrite)

Examples:
  bootstrap use app/fish
  bootstrap profile laptop
  bootstrap restow app/kitty
  bootstrap adopt app/nvim
  bootstrap undo app/kitty
  bootstrap undo profile laptop
  bootstrap secrets
  bootstrap doctor
  bootstrap status app/fish
  bootstrap diff
EOF
	exit 1
}

err() { echo -e "${RED}error:${NC} $*" >&2; }
warn() { echo -e "${YELLOW}warn:${NC} $*" >&2; }
info() { echo -e "${CYAN}→${NC} $*"; }
ok() { echo -e "  ${GREEN}✓${NC} $*"; }

# Execute a command — or print it in dry-run mode
run() {
	if ((DRY_RUN)); then
		echo -e "  ${CYAN}[dry-run]${NC} $*"
	else
		"$@"
	fi
}

confirm() {
	if ((FORCE)); then
		echo "overwrite"
		return
	fi
	local prompt="$1" ans
	read -rp "$prompt [s=skip / o=overwrite / b=backup]: " ans
	case "$ans" in
	s | S | skip) echo "skip" ;;
	o | O | overwrite) echo "overwrite" ;;
	b | B | backup) echo "backup" ;;
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

module_metadata_file() {
	local module_ref
	module_ref="$(normalize_module_ref "$1")" || return 1
	printf '%s\n' "${CONFIG_ROOT}/${module_ref}/.bootstrap.json"
}

directory_links_for_module() {
	local module_ref metadata
	module_ref="$(normalize_module_ref "$1")" || return 1
	metadata="$(module_metadata_file "$module_ref")" || return 1

	[[ -f "$metadata" ]] || return 0

	python3 - "$metadata" <<'PY'
import json
import sys
from pathlib import Path

metadata = Path(sys.argv[1])
data = json.loads(metadata.read_text())

for item in data.get("directory_links", []):
    if isinstance(item, str) and item.strip():
        print(item.strip().strip("/"))
PY
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
		*Repos/dotfiles/app/* | *Repos/dotfiles/desktop/* | *Repos/dotfiles/misc/* | *Repos/dotfiles/system/*)
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

	# Truncate manifest (skip in dry-run to avoid corrupting it)
	if ! ((DRY_RUN)); then
		: >"$mf"
	fi
	info "Deploying ${module_ref}"

	local count=0
	local linked_dirs=()

	# --- Declared directory links (from .bootstrap.json) ---
	while IFS= read -r rel; do
		[[ -z "$rel" ]] && continue

		local src="${src_dir}/${rel}"
		local target="${TARGET}/${rel}"

		if [[ ! -d "$src" ]]; then
			err "Declared directory link is not a directory: $src"
			return 1
		fi

		local action
		action="$(resolve_conflict "$target" "$src")"

		case "$action" in
		skip)
			if [[ -L "$target" ]] && [[ "$(readlink "$target")" == "$src" ]]; then
				ok "$rel (already linked dir)"
				linked_dirs+=("$rel")
			else
				warn "$rel (skipped dir)"
			fi
			;;
		overwrite)
			run rm -rf "$target"
			;&
		create)
			ensure_target_parent "$target"
			run ln -sfn "$src" "$target"
			if ! ((DRY_RUN)); then echo "$target" >>"$mf"; fi
			ok "$rel/"
			linked_dirs+=("$rel")
			((count++)) || true
			;;
		backup)
			run mv "$target" "${target}.bak"
			warn "$rel (backed up to ${target}.bak)"
			ensure_target_parent "$target"
			run ln -sfn "$src" "$target"
			if ! ((DRY_RUN)); then echo "$target" >>"$mf"; fi
			ok "$rel/"
			linked_dirs+=("$rel")
			((count++)) || true
			;;
		esac
	done < <(directory_links_for_module "$module_ref")

	# --- Auto directory-folding: link whole .config/<app> dirs when safe ---
	# A target dir is "ours" (safe to replace) when every entry in it is a symlink
	# pointing into this dotfiles repo's config dir. That covers both the "fresh
	# install" case (dir absent) and the "previously deployed file-by-file" case.
	_dir_is_ours() {
		local dir="$1" cfg_root="$2"
		[[ -d "$dir" ]] || return 0 # absent → safe
		# Dir is already a symlink pointing into our config root → already ours
		if [[ -L "$dir" ]]; then
			local lnk
			lnk="$(readlink "$dir")"
			case "$lnk" in "$cfg_root"/*) return 0 ;; esac
		fi
		[[ -n "$(ls -A "$dir" 2>/dev/null)" ]] || return 0 # empty → safe
		local entry
		while IFS= read -r -d '' entry; do
			[[ -L "$entry" ]] || return 1
			local lnk
			lnk="$(readlink "$entry")"
			case "$lnk" in
			"$cfg_root"/*) ;;
			*) return 1 ;;
			esac
		done < <(find "$dir" -mindepth 1 -maxdepth 1 -print0 2>/dev/null)
		return 0
	}

	while IFS= read -r rel; do
		[[ -z "$rel" ]] && continue

		# Skip if already covered by a declared directory_link
		local already_declared=0
		local ld
		for ld in "${linked_dirs[@]}"; do
			if [[ "$rel" == "$ld" ]] || [[ "$rel" == "$ld"/* ]]; then
				already_declared=1
				break
			fi
		done
		((already_declared)) && continue

		local src="${src_dir}/${rel}"
		local target="${TARGET}/${rel}"

		# Fold when target is absent, empty, or contains only our own symlinks
		if _dir_is_ours "$target" "$CONFIG_ROOT"; then
			[[ -d "$target" && ! -L "$target" ]] && run rm -rf "$target"
			ensure_target_parent "$target"
			run ln -sfn "$src" "$target"
			if ! ((DRY_RUN)); then echo "$target" >>"$mf"; fi
			ok "$rel/ (auto-folded)"
			linked_dirs+=("$rel")
			((count++)) || true
		fi
	done < <(
		find "$src_dir" -mindepth 2 -type d 2>/dev/null |
			sed "s#^${src_dir}/##" |
			sort || true
	)

	# --- Per-file symlinks ---
	while IFS= read -r -d '' src; do
		local rel="${src#"${src_dir}/"}"
		local target="${TARGET}/${rel}"
		local skip_file=0
		local linked_dir

		if [[ "$rel" == ".bootstrap.json" ]]; then
			continue
		fi

		for linked_dir in "${linked_dirs[@]}"; do
			if [[ "$rel" == "$linked_dir"/* ]]; then
				skip_file=1
				break
			fi
		done

		if ((skip_file)); then
			continue
		fi

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
			run rm -rf "$target"
			;&
		create)
			ensure_target_parent "$target"
			run ln -sf "$src" "$target"
			if ! ((DRY_RUN)); then echo "$target" >>"$mf"; fi
			ok "$rel"
			((count++)) || true
			;;
		backup)
			run mv "$target" "${target}.bak"
			warn "$rel (backed up to ${target}.bak)"
			ensure_target_parent "$target"
			run ln -sf "$src" "$target"
			if ! ((DRY_RUN)); then echo "$target" >>"$mf"; fi
			((count++)) || true
			;;
		esac
	done < <(find "$src_dir" -type f -print0)

	echo ""
	info "Linked $count entries in ${module_ref}"
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
		info "No manifest for ${module_ref}, skipping validation\n"
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
		conf | cfg | toml | yml | yaml)
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
	done <"$mf"

	echo ""
	if ((failed > 0)); then
		err "Validation: $passed passed, $failed failed in ${module_ref}\n"
		return 1
	fi

	ok "Validation: $passed passed in ${module_ref}\n"
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
			run rm "$target"
			ok "Removed: $target"
			((count++)) || true
		else
			warn "Not a symlink, skipping: $target"
		fi
	done <"$mf"

	if ! ((DRY_RUN)); then run rm "$mf"; fi
	echo ""
	info "Rolled back $count symlinks in ${module_ref}"
	return 0
}

restow_module() {
	local module_ref
	module_ref="$(normalize_module_ref "$1")" || return 1
	info "Restowing: ${module_ref}"
	undo_module "$module_ref" 2>/dev/null || true
	symlink_module "$module_ref" && validate_module "$module_ref" || true
}

adopt_module() {
	local module_ref src_dir
	module_ref="$(normalize_module_ref "$1")" || return 1
	src_dir="${CONFIG_ROOT}/${module_ref}"
	[[ -d "$src_dir" ]] || {
		err "Module not found: ${module_ref}"
		return 1
	}
	info "Adopting existing \$HOME files into ${module_ref}"

	while IFS= read -r -d '' src; do
		local rel="${src#"${src_dir}/"}"
		[[ "$rel" == ".bootstrap.json" ]] && continue
		local target="${TARGET}/${rel}"
		if [[ -e "$target" && ! -L "$target" ]]; then
			run cp -a "$target" "$src"
			ok "adopted $rel"
		fi
	done < <(find "$src_dir" -type f -print0)

	symlink_module "$module_ref"
}

undo_profile() {
	local name="$1"
	local profile="${PROFILES_DIR}/${name}.json"
	[[ -f "$profile" ]] || {
		err "Profile not found: $profile"
		return 1
	}
	info "Rolling back profile: $name"

	local modules
	modules=$(python3 -c "
import json, sys
p = json.load(open('${profile}'))
mods = p.get('modules', [])
for k in ['apps','desktop','misc','system']:
    mods += p.get(k, [])
print('\n'.join(mods))
")

	while IFS= read -r module_ref; do
		[[ -z "$module_ref" ]] && continue
		undo_module "$module_ref" || warn "${module_ref} undo failed, continuing..."
	done <<<"$modules"

	ok "Profile rollback complete"
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

	if ((failed > 0)); then
		err "Profile deploy finished with $failed failures"
		return 1
	fi

	ok "Profile deploy complete"
	deploy_secrets
}

deploy_secrets() {
	[[ -d "$SECRETS_DIR" ]] || {
		warn "No secrets/ dir found"
		return 0
	}
	local sops_target="${HOME}/.config/sops"
	local script_target="${HOME}/.local/script"
	run mkdir -p "$sops_target" "$script_target"
	run ln -sf "${SECRETS_DIR}/secrets.yaml" "${sops_target}/secrets.yaml"
	run ln -sf "${SECRETS_DIR}/load.sh" "${script_target}/secrets-load"
	ok "secrets linked (secrets/secrets.yaml → ~/.config/sops/secrets.yaml, secrets/load.sh → ~/.local/script/secrets-load)"
}

# ---------------------------------------------------------------------------
# Inspection commands
# ---------------------------------------------------------------------------

cmd_doctor() {
	if [[ ! -d "$MANIFEST_DIR" ]] || [[ -z "$(ls -A "$MANIFEST_DIR" 2>/dev/null)" ]]; then
		info "No deployed modules found (manifest dir empty or absent)"
		return 0
	fi

	local ok_count=0 broken_count=0

	while IFS= read -r -d '' mf; do
		local mf_base
		mf_base="$(basename "$mf")"
		local module_ref="${mf_base//__//}"

		info "Checking ${module_ref}"

		while IFS= read -r target; do
			[[ -z "$target" ]] && continue

			if [[ ! -L "$target" ]]; then
				echo -e "  ${RED}✗${NC} ${target} (not a symlink — was it overwritten?)"
				((broken_count++)) || true
			elif [[ ! -e "$target" ]]; then
				local dest
				dest="$(readlink "$target")"
				echo -e "  ${RED}✗${NC} ${target} (dangling symlink → ${dest})"
				((broken_count++)) || true
			else
				ok "$target"
				((ok_count++)) || true
			fi
		done <"$mf"
	done < <(find "$MANIFEST_DIR" -maxdepth 1 -type f -print0 2>/dev/null)

	echo ""
	if ((broken_count > 0)); then
		echo -e "${CYAN}Doctor:${NC} ${ok_count} OK, ${RED}${broken_count} broken${NC}"
		return 1
	else
		echo -e "${CYAN}Doctor:${NC} ${GREEN}${ok_count} OK, 0 broken${NC}"
		return 0
	fi
}

_status_one() {
	local module_ref="$1"
	local mf
	mf="$(manifest_file "$module_ref")" || return 1
	local src_dir
	src_dir="$(module_source_dir "$module_ref")" || return 1

	info "Status: ${module_ref}"

	if [[ ! -f "$mf" ]]; then
		echo -e "  ${YELLOW}[NOT DEPLOYED]${NC}"
		return 0
	fi

	# Build a lookup of all manifest entries
	local -a manifest_entries=()
	while IFS= read -r entry; do
		[[ -z "$entry" ]] && continue
		manifest_entries+=("$entry")
	done <"$mf"

	# Walk all source files (excluding .bootstrap.json)
	while IFS= read -r -d '' src; do
		local rel="${src#"${src_dir}/"}"
		[[ "$rel" == ".bootstrap.json" ]] && continue

		local target="${TARGET}/${rel}"
		local covered=0
		local covered_entry=""

		# Check if the target itself is in the manifest, or a parent dir is
		local entry
		for entry in "${manifest_entries[@]}"; do
			if [[ "$entry" == "$target" ]]; then
				covered=1
				covered_entry="$entry"
				break
			fi
			# Check if a parent directory is in the manifest (directory-folded)
			if [[ "$target" == "${entry}/"* ]]; then
				covered=1
				covered_entry="$entry"
				break
			fi
		done

		if ((covered)); then
			if [[ -L "$covered_entry" && -e "$covered_entry" ]]; then
				ok "${rel} (linked)"
			elif [[ -L "$covered_entry" && ! -e "$covered_entry" ]]; then
				echo -e "  ${RED}[BROKEN]${NC} ${rel} (linked in manifest but symlink is broken)"
			else
				echo -e "  ${YELLOW}[REGULAR]${NC} ${rel} (in manifest but not a symlink — drift?)"
			fi
		else
			echo -e "  ${RED}✗${NC} ${rel}  ${YELLOW}[UNLINKED — run: setup restow ${module_ref}]${NC}"
		fi
	done < <(find "$src_dir" -type f -print0 2>/dev/null)
}

cmd_status() {
	local module_ref_arg="${1:-}"

	if [[ -n "$module_ref_arg" ]]; then
		local module_ref
		module_ref="$(normalize_module_ref "$module_ref_arg")" || return 1
		_status_one "$module_ref"
	else
		if [[ ! -d "$MANIFEST_DIR" ]] || [[ -z "$(ls -A "$MANIFEST_DIR" 2>/dev/null)" ]]; then
			info "No deployed modules found (manifest dir empty or absent)"
			return 0
		fi

		while IFS= read -r -d '' mf; do
			local mf_base
			mf_base="$(basename "$mf")"
			local module_ref="${mf_base//__//}"
			_status_one "$module_ref"
			echo ""
		done < <(find "$MANIFEST_DIR" -maxdepth 1 -type f -print0 2>/dev/null)
	fi
}

_diff_one() {
	local module_ref="$1"
	local mf
	mf="$(manifest_file "$module_ref")" || return 1

	info "Diff: ${module_ref}"

	if [[ ! -f "$mf" ]]; then
		echo -e "  ${YELLOW}[NOT DEPLOYED]${NC}"
		return 0
	fi

	while IFS= read -r target; do
		[[ -z "$target" ]] && continue

		if [[ ! -e "$target" && ! -L "$target" ]]; then
			echo -e "  ${YELLOW}[MISSING]${NC}  ${target}"
		elif [[ -L "$target" ]]; then
			local dest
			dest="$(readlink "$target")"
			case "$dest" in
			"${CONFIG_ROOT}"/*)
				echo -e "  ${GREEN}[SYMLINK]${NC}  ${target} → ${dest}"
				;;
			*)
				echo -e "  ${YELLOW}[FOREIGN]${NC}  ${target} → ${dest}"
				;;
			esac
		else
			echo -e "  ${RED}[REGULAR]${NC}  ${target}  ← drift! was symlink, now regular file"
			echo -e "  Run: setup restow ${module_ref}   to re-link"
		fi
	done <"$mf"

	return 0
}

cmd_diff() {
	local module_ref_arg="${1:-}"

	if [[ -n "$module_ref_arg" ]]; then
		local module_ref
		module_ref="$(normalize_module_ref "$module_ref_arg")" || return 1
		_diff_one "$module_ref"
	else
		if [[ ! -d "$MANIFEST_DIR" ]] || [[ -z "$(ls -A "$MANIFEST_DIR" 2>/dev/null)" ]]; then
			info "No deployed modules found (manifest dir empty or absent)"
			return 0
		fi

		local symlink_count=0 foreign_count=0 regular_count=0 missing_count=0

		while IFS= read -r -d '' mf; do
			local mf_base
			mf_base="$(basename "$mf")"
			local module_ref="${mf_base//__//}"
			_diff_one "$module_ref"
			echo ""

			# Tally counts from this module's manifest
			while IFS= read -r target; do
				[[ -z "$target" ]] && continue
				if [[ ! -e "$target" && ! -L "$target" ]]; then
					((missing_count++)) || true
				elif [[ -L "$target" ]]; then
					local dest
					dest="$(readlink "$target")"
					case "$dest" in
					"${CONFIG_ROOT}"/*)
						((symlink_count++)) || true
						;;
					*)
						((foreign_count++)) || true
						;;
					esac
				else
					((regular_count++)) || true
				fi
			done <"$mf"
		done < <(find "$MANIFEST_DIR" -maxdepth 1 -type f -print0 2>/dev/null)

		info "Diff: ${symlink_count} symlinks, ${regular_count} drift (regular), ${foreign_count} foreign, ${missing_count} missing"
	fi
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
		[[ -z "$name" ]] && {
			err "Expected profile name"
			usage
		}
		deploy_profile "$name"
		;;
	restow)
		shift
		local module_ref="${1:-}"
		[[ -z "$module_ref" ]] && usage
		restow_module "$module_ref"
		;;
	adopt)
		shift
		local module_ref="${1:-}"
		[[ -z "$module_ref" ]] && usage
		adopt_module "$module_ref"
		;;
	secrets)
		deploy_secrets
		;;
	doctor)
		cmd_doctor
		;;
	status)
		shift
		cmd_status "${1:-}"
		;;
	diff)
		shift
		cmd_diff "${1:-}"
		;;
	undo)
		shift
		local sub="${1:-}"
		if [[ "$sub" == "profile" ]]; then
			local name="${2:-}"
			[[ -z "$name" ]] && {
				err "Expected profile name"
				usage
			}
			undo_profile "$name"
		else
			[[ -z "$sub" ]] && usage
			local module_ref
			module_ref="$(normalize_module_ref "$sub")" || exit 1
			undo_module "$module_ref"
		fi
		;;
	*)
		usage
		;;
	esac
}

main "$@"
