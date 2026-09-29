#!/bin/sh
set -eu

DOTFILES_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
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

has_args=""
for a in "$@"; do
	case "$a" in
	--dry-run) DRY_RUN=1 ;;
	--force) FORCE=1 ;;
	*)
		if [ -z "$has_args" ]; then
			set -- "$a"
			has_args="1"
		else
			set -- "$@" "$a"
		fi
		;;
	esac
done
[ -z "$has_args" ] && set --

usage() {
	cat <<'EOF'
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

err() { printf "${RED}error:${NC} %s\n" "$*" >&2; }
warn() { printf "${YELLOW}warn:${NC} %s\n" "$*" >&2; }
info() { printf "${CYAN}→${NC} %s\n" "$*"; }
ok() { printf "  ${GREEN}✓${NC} %s\n" "$*"; }

# Execute a command — or print it in dry-run mode
run() {
	if [ "$DRY_RUN" -eq 1 ]; then
		printf "  ${CYAN}[dry-run]${NC} %s\n" "$*"
	else
		"$@"
	fi
}

confirm() {
	if [ "$FORCE" -eq 1 ]; then
		echo "overwrite"
		return
	fi
	if [ "$DRY_RUN" -eq 1 ] || [ ! -t 0 ]; then
		echo "skip"
		return
	fi
	prompt="$1"
	printf "%s [s=skip / o=overwrite / b=backup]: " "$prompt"
	read -r ans
	case "$ans" in
	s | S | skip) echo "skip" ;;
	o | O | overwrite) echo "overwrite" ;;
	b | B | backup) echo "backup" ;;
	*) echo "skip" ;;
	esac
}

normalize_module_ref() {
	module_ref="${1:-}"
	module_ref="${module_ref#config/}"
	module_ref="${module_ref#/}"

	case "$module_ref" in
	*/*) ;;
	*)
		err "Expected <category/module> (e.g. app/fish)"
		return 1
		;;
	esac

	printf '%s\n' "$module_ref"
}

module_source_dir() {
	module_ref="$(normalize_module_ref "$1")" || return 1
	printf '%s\n' "${CONFIG_ROOT}/${module_ref}"
}

manifest_file() {
	module_ref="$(normalize_module_ref "$1")" || return 1
	sanitized="$(printf '%s' "$module_ref" | sed 's#/#__#g')"
	printf '%s\n' "${MANIFEST_DIR}/${sanitized}"
}

module_metadata_file() {
	module_ref="$(normalize_module_ref "$1")" || return 1
	printf '%s\n' "${CONFIG_ROOT}/${module_ref}/.bootstrap.json"
}

directory_links_for_module() {
	module_ref="$(normalize_module_ref "$1")" || return 1
	metadata="$(module_metadata_file "$module_ref")" || return 1

	[ -f "$metadata" ] || return 0

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
	profile_path="$1"
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
	target="$1"
	source="$2"

	if [ -L "$target" ]; then
		raw_link="$(readlink "$target" 2>/dev/null || true)"
		existing_real="$(readlink -f "$target" 2>/dev/null || realpath "$target" 2>/dev/null || printf '%s' "$raw_link")"
		source_real="$(readlink -f "$source" 2>/dev/null || realpath "$source" 2>/dev/null || echo "$source")"

		if [ "$existing_real" = "$source_real" ]; then
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

	if [ -e "$target" ]; then
		warn "File exists at $target (not a symlink)"
		confirm "How to handle?"
		return
	fi

	echo "create"
}

ensure_target_parent() {
	target="$1"
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

_dir_is_ours() {
	check_dir="$1"
	cfg_root="$2"
	[ -d "$check_dir" ] || return 0 # absent -> safe
	if [ -L "$check_dir" ]; then
		lnk="$(readlink "$check_dir" 2>/dev/null || true)"
		case "$lnk" in "$cfg_root"/*) return 0 ;; esac
	fi
	[ -n "$(ls -A "$check_dir" 2>/dev/null)" ] || return 0 # empty -> safe

	entries="$(find "$check_dir" -mindepth 1 -maxdepth 1 2>/dev/null)"
	[ -z "$entries" ] && return 0
	for entry in $entries; do
		[ -L "$entry" ] || return 1
		lnk="$(readlink "$entry" 2>/dev/null || true)"
		case "$lnk" in
		"$cfg_root"/*) ;;
		*) return 1 ;;
		esac
	done
	return 0
}

symlink_module() {
	module_ref="$(normalize_module_ref "$1")" || return 1
	src_dir="$(module_source_dir "$module_ref")" || return 1
	mf="$(manifest_file "$module_ref")" || return 1

	if [ ! -d "$src_dir" ]; then
		err "Source directory not found: $src_dir"
		return 1
	fi

	# Truncate manifest (skip in dry-run to avoid corrupting it)
	if [ "$DRY_RUN" -eq 0 ]; then
		: >"$mf"
	fi
	info "Deploying ${module_ref}"

	count=0
	linked_dirs=""

	# --- Declared directory links (from .bootstrap.json) ---
	declared_links="$(directory_links_for_module "$module_ref")"
	if [ -n "$declared_links" ]; then
		for rel in $declared_links; do
			[ -z "$rel" ] && continue

			src="${src_dir}/${rel}"
			target="${TARGET}/${rel}"

			if [ ! -d "$src" ]; then
				err "Declared directory link is not a directory: $src"
				return 1
			fi

			action="$(resolve_conflict "$target" "$src")"

			case "$action" in
			skip)
				if [ -L "$target" ] && [ "$(readlink "$target" 2>/dev/null || true)" = "$src" ]; then
					ok "$rel (already linked dir)"
					linked_dirs="${linked_dirs}${linked_dirs:+ }$rel"
				else
					warn "$rel (skipped dir)"
				fi
				;;
			overwrite)
				run rm -rf "$target"
				ensure_target_parent "$target"
				run ln -sfn "$src" "$target"
				if [ "$DRY_RUN" -eq 0 ]; then echo "$target" >>"$mf"; fi
				ok "$rel/"
				linked_dirs="${linked_dirs}${linked_dirs:+ }$rel"
				count=$((count + 1))
				;;
			create)
				ensure_target_parent "$target"
				run ln -sfn "$src" "$target"
				if [ "$DRY_RUN" -eq 0 ]; then echo "$target" >>"$mf"; fi
				ok "$rel/"
				linked_dirs="${linked_dirs}${linked_dirs:+ }$rel"
				count=$((count + 1))
				;;
			backup)
				run mv "$target" "${target}.bak"
				warn "$rel (backed up to ${target}.bak)"
				ensure_target_parent "$target"
				run ln -sfn "$src" "$target"
				if [ "$DRY_RUN" -eq 0 ]; then echo "$target" >>"$mf"; fi
				ok "$rel/"
				linked_dirs="${linked_dirs}${linked_dirs:+ }$rel"
				count=$((count + 1))
				;;
			esac
		done
	fi

	# --- Auto directory-folding: link whole .config/<app> dirs when safe ---
	subdirs="$(find "$src_dir" -mindepth 2 -type d 2>/dev/null | sed "s#^${src_dir}/##" | sort || true)"
	if [ -n "$subdirs" ]; then
		for rel in $subdirs; do
			[ -z "$rel" ] && continue

			already_declared=0
			for ld in $linked_dirs; do
				if [ "$rel" = "$ld" ]; then
					already_declared=1
					break
				fi
				case "$rel" in
				"$ld"/*)
					already_declared=1
					break
					;;
				esac
			done
			[ "$already_declared" -eq 1 ] && continue

			src="${src_dir}/${rel}"
			target="${TARGET}/${rel}"

			if _dir_is_ours "$target" "$CONFIG_ROOT"; then
				if [ -d "$target" ] && [ ! -L "$target" ]; then
					run rm -rf "$target"
				fi
				ensure_target_parent "$target"
				run ln -sfn "$src" "$target"
				if [ "$DRY_RUN" -eq 0 ]; then echo "$target" >>"$mf"; fi
				ok "$rel/ (auto-folded)"
				linked_dirs="${linked_dirs}${linked_dirs:+ }$rel"
				count=$((count + 1))
			fi
		done
	fi

	# --- Per-file symlinks ---
	files="$(find "$src_dir" -type f 2>/dev/null | sed "s#^${src_dir}/##" || true)"
	if [ -n "$files" ]; then
		for rel in $files; do
			[ -z "$rel" ] && continue
			[ "$rel" = ".bootstrap.json" ] && continue

			src="${src_dir}/${rel}"
			target="${TARGET}/${rel}"

			skip_file=0
			for ld in $linked_dirs; do
				case "$rel" in
				"$ld"/*)
					skip_file=1
					break
					;;
				esac
			done
			[ "$skip_file" -eq 1 ] && continue

			action="$(resolve_conflict "$target" "$src")"

			case "$action" in
			skip)
				if [ -L "$target" ] && [ "$(readlink "$target" 2>/dev/null || true)" = "$src" ]; then
					ok "$rel (already linked)"
				else
					warn "$rel (skipped)"
				fi
				;;
			overwrite)
				run rm -rf "$target"
				ensure_target_parent "$target"
				run ln -sf "$src" "$target"
				if [ "$DRY_RUN" -eq 0 ]; then echo "$target" >>"$mf"; fi
				ok "$rel"
				count=$((count + 1))
				;;
			create)
				ensure_target_parent "$target"
				run ln -sf "$src" "$target"
				if [ "$DRY_RUN" -eq 0 ]; then echo "$target" >>"$mf"; fi
				ok "$rel"
				count=$((count + 1))
				;;
			backup)
				run mv "$target" "${target}.bak"
				warn "$rel (backed up to ${target}.bak)"
				ensure_target_parent "$target"
				run ln -sf "$src" "$target"
				if [ "$DRY_RUN" -eq 0 ]; then echo "$target" >>"$mf"; fi
				ok "$rel"
				count=$((count + 1))
				;;
			esac
		done
	fi

	printf "\n"
	info "Linked $count entries in ${module_ref}"
	return 0
}

validate_json_file() {
	target="$1"
	python3 -m json.tool "$target" >/dev/null 2>&1 && ok "json valid: $(basename "$target")" || {
		err "json invalid: $target"
		return 1
	}
}

validate_module() {
	module_ref="$(normalize_module_ref "$1")" || return 1
	mf="$(manifest_file "$module_ref")" || return 1
	passed=0
	failed=0

	if [ ! -f "$mf" ]; then
		info "No manifest for ${module_ref}, skipping validation"
		return 0
	fi

	while IFS= read -r target; do
		[ -z "$target" ] && continue

		if [ ! -e "$target" ]; then
			err "Broken symlink: $target"
			failed=$((failed + 1))
			continue
		fi

		ext="${target##*.}"
		case "$ext" in
		fish)
			if command -v fish >/dev/null 2>&1; then
				if fish -n "$target" 2>/dev/null; then
					ok "fish syntax: $(basename "$target")"
				else
					err "fish syntax: $target"
					failed=$((failed + 1))
				fi
			fi
			;;
		json)
			if validate_json_file "$target"; then
				:
			else
				failed=$((failed + 1))
			fi
			;;
		kdl)
			ok "kdl: $(basename "$target")"
			;;
		conf | cfg | toml | yml | yaml)
			ok "readable: $(basename "$target")"
			;;
		esac

		first_line="$(head -n1 "$target" 2>/dev/null || true)"
		case "$first_line" in
		\#!/*)
			if [ -x "$target" ]; then
				ok "executable: $(basename "$target")"
			else
				warn "Missing executable bit: $target"
				if chmod +x "$target"; then
					ok "fixed: chmod +x $(basename "$target")"
				fi
			fi
			;;
		esac

		if [ "$(basename "$target")" = "secrets.yaml" ]; then
			if command -v sops >/dev/null 2>&1; then
				if sops -d "$target" >/dev/null 2>&1; then
					ok "secrets decrypt: $(basename "$target")"
				else
					err "secrets decrypt failed: $target"
					failed=$((failed + 1))
				fi
			else
				warn "sops not found, skipping secrets check"
			fi
		fi

		passed=$((passed + 1))
	done <"$mf"

	printf "\n"
	if [ "$failed" -gt 0 ]; then
		err "Validation: $passed passed, $failed failed in ${module_ref}"
		return 1
	fi

	ok "Validation: $passed passed in ${module_ref}"
}

undo_module() {
	module_ref="$(normalize_module_ref "$1")" || return 1
	mf="$(manifest_file "$module_ref")" || return 1

	if [ ! -f "$mf" ]; then
		warn "No manifest found for ${module_ref}"
		return 1
	fi

	info "Rolling back ${module_ref}"

	count=0
	while IFS= read -r target; do
		[ -z "$target" ] && continue

		if [ -L "$target" ]; then
			run rm "$target"
			ok "Removed: $target"
			count=$((count + 1))
		else
			warn "Not a symlink, skipping: $target"
		fi
	done <"$mf"

	if [ "$DRY_RUN" -eq 0 ]; then run rm "$mf"; fi
	printf "\n"
	info "Rolled back $count symlinks in ${module_ref}"
	return 0
}

restow_module() {
	module_ref="$(normalize_module_ref "$1")" || return 1
	info "Restowing: ${module_ref}"
	undo_module "$module_ref" 2>/dev/null || true
	symlink_module "$module_ref" && validate_module "$module_ref" || true
}

adopt_module() {
	module_ref="$(normalize_module_ref "$1")" || return 1
	src_dir="${CONFIG_ROOT}/${module_ref}"
	if [ ! -d "$src_dir" ]; then
		err "Module not found: ${module_ref}"
		return 1
	fi
	info "Adopting existing \$HOME files into ${module_ref}"

	files="$(find "$src_dir" -type f 2>/dev/null | sed "s#^${src_dir}/##" || true)"
	for rel in $files; do
		[ -z "$rel" ] && continue
		[ "$rel" = ".bootstrap.json" ] && continue
		src="${src_dir}/${rel}"
		target="${TARGET}/${rel}"
		if [ -e "$target" ] && [ ! -L "$target" ]; then
			run cp -a "$target" "$src"
			ok "adopted $rel"
		fi
	done

	symlink_module "$module_ref"
}

# Prefer a device-local override profile when present. `<name>.local.json` is
# gitignored (*.local.*) so each machine can pin its own module set without
# touching the tracked profile. Replace semantics — the .local file is used
# instead of the base, not merged.
resolve_profile() {
	name="$1"
	if [ -f "${PROFILES_DIR}/${name}.local.json" ]; then
		echo "${PROFILES_DIR}/${name}.local.json"
	else
		echo "${PROFILES_DIR}/${name}.json"
	fi
}

undo_profile() {
	name="$1"
	profile="$(resolve_profile "$name")"
	if [ ! -f "$profile" ]; then
		err "Profile not found: $profile"
		return 1
	fi
	info "Rolling back profile: $name"

	modules="$(python3 -c "
import json, sys
p = json.load(open('${profile}'))
mods = p.get('modules', [])
for k in ['apps','desktop','misc','system']:
    mods += p.get(k, [])
print('\n'.join(mods))
")"

	for module_ref in $modules; do
		[ -z "$module_ref" ] && continue
		undo_module "$module_ref" || warn "${module_ref} undo failed, continuing..."
	done

	ok "Profile rollback complete"
}

deploy_profile() {
	name="$1"
	profile="$(resolve_profile "$name")"

	if [ ! -f "$profile" ]; then
		err "Profile not found: $profile"
		return 1
	fi

	case "$profile" in
	*.local.json) info "Using device-local profile: ${profile##*/}" ;;
	esac
	info "Deploying profile: $name"
	failed=0

	modules="$(profile_modules "$profile")"
	for module_ref in $modules; do
		[ -z "$module_ref" ] && continue
		if symlink_module "$module_ref" && validate_module "$module_ref"; then
			:
		else
			failed=$((failed + 1))
			warn "$module_ref failed, continuing..."
		fi
	done

	if [ "$failed" -gt 0 ]; then
		err "Profile deploy finished with $failed failures"
		return 1
	fi

	ok "Profile deploy complete"
	deploy_secrets
}

deploy_secrets() {
	if [ ! -d "$SECRETS_DIR" ]; then
		warn "No secrets/ dir found"
		return 0
	fi
	sops_target="${HOME}/.config/sops"
	script_target="${HOME}/.local/script"
	run mkdir -p "$sops_target" "$script_target"
	run ln -sf "${SECRETS_DIR}/secrets.yaml" "${sops_target}/secrets.yaml"
	run ln -sf "${SECRETS_DIR}/load.sh" "${script_target}/secrets-load"
	ok "secrets linked (secrets/secrets.yaml → ~/.config/sops/secrets.yaml, secrets/load.sh → ~/.local/script/secrets-load)"
}

# ---------------------------------------------------------------------------
# Inspection commands
# ---------------------------------------------------------------------------

cmd_doctor() {
	if [ ! -d "$MANIFEST_DIR" ] || [ -z "$(ls -A "$MANIFEST_DIR" 2>/dev/null)" ]; then
		info "No deployed modules found (manifest dir empty or absent)"
		return 0
	fi

	ok_count=0
	broken_count=0

	manifest_files="$(find "$MANIFEST_DIR" -maxdepth 1 -type f 2>/dev/null || true)"
	for mf in $manifest_files; do
		[ -z "$mf" ] && continue
		mf_base="$(basename "$mf")"
		module_ref="$(printf '%s' "$mf_base" | sed 's#__#/#g')"

		info "Checking ${module_ref}"

		while IFS= read -r target; do
			[ -z "$target" ] && continue

			if [ ! -L "$target" ]; then
				printf "  ${RED}✗${NC} %s (not a symlink — was it overwritten?)\n" "${target}"
				broken_count=$((broken_count + 1))
			elif [ ! -e "$target" ]; then
				dest="$(readlink "$target" 2>/dev/null || true)"
				printf "  ${RED}✗${NC} %s (dangling symlink → %s)\n" "${target}" "${dest}"
				broken_count=$((broken_count + 1))
			else
				ok "$target"
				ok_count=$((ok_count + 1))
			fi
		done <"$mf"
	done

	printf "\n"
	if [ "$broken_count" -gt 0 ]; then
		printf "${CYAN}Doctor:${NC} %s OK, ${RED}%s broken${NC}\n" "${ok_count}" "${broken_count}"
		return 1
	else
		printf "${CYAN}Doctor:${NC} ${GREEN}%s OK${NC}, 0 broken\n" "${ok_count}"
		return 0
	fi
}

_status_one() {
	module_ref="$1"
	mf="$(manifest_file "$module_ref")" || return 1
	src_dir="$(module_source_dir "$module_ref")" || return 1

	info "Status: ${module_ref}"

	if [ ! -f "$mf" ]; then
		printf "  ${YELLOW}[NOT DEPLOYED]${NC}\n"
		return 0
	fi

	files="$(find "$src_dir" -type f 2>/dev/null | sed "s#^${src_dir}/##" || true)"
	for rel in $files; do
		[ -z "$rel" ] && continue
		[ "$rel" = ".bootstrap.json" ] && continue

		target="${TARGET}/${rel}"
		covered=0
		covered_entry=""

		while IFS= read -r entry; do
			[ -z "$entry" ] && continue
			if [ "$entry" = "$target" ]; then
				covered=1
				covered_entry="$entry"
				break
			fi
			case "$target" in
			"${entry}"/*)
				covered=1
				covered_entry="$entry"
				break
				;;
			esac
		done <"$mf"

		if [ "$covered" -eq 1 ]; then
			if [ -L "$covered_entry" ] && [ -e "$covered_entry" ]; then
				ok "${rel} (linked)"
			elif [ -L "$covered_entry" ] && [ ! -e "$covered_entry" ]; then
				printf "  ${RED}[BROKEN]${NC} %s (linked in manifest but symlink is broken)\n" "${rel}"
			else
				printf "  ${YELLOW}[REGULAR]${NC} %s (in manifest but not a symlink — drift?)\n" "${rel}"
			fi
		else
			printf "  ${RED}✗${NC} %s  ${YELLOW}[UNLINKED — run: setup restow %s]${NC}\n" "${rel}" "${module_ref}"
		fi
	done
}

cmd_status() {
	module_ref_arg="${1:-}"

	if [ -n "$module_ref_arg" ]; then
		module_ref="$(normalize_module_ref "$module_ref_arg")" || return 1
		_status_one "$module_ref"
	else
		if [ ! -d "$MANIFEST_DIR" ] || [ -z "$(ls -A "$MANIFEST_DIR" 2>/dev/null)" ]; then
			info "No deployed modules found (manifest dir empty or absent)"
			return 0
		fi

		manifest_files="$(find "$MANIFEST_DIR" -maxdepth 1 -type f 2>/dev/null || true)"
		for mf in $manifest_files; do
			[ -z "$mf" ] && continue
			mf_base="$(basename "$mf")"
			module_ref="$(printf '%s' "$mf_base" | sed 's#__#/#g')"
			_status_one "$module_ref"
			printf "\n"
		done
	fi
}

_diff_one() {
	module_ref="$1"
	mf="$(manifest_file "$module_ref")" || return 1

	info "Diff: ${module_ref}"

	if [ ! -f "$mf" ]; then
		printf "  ${YELLOW}[NOT DEPLOYED]${NC}\n"
		return 0
	fi

	while IFS= read -r target; do
		[ -z "$target" ] && continue

		if [ ! -e "$target" ] && [ ! -L "$target" ]; then
			printf "  ${YELLOW}[MISSING]${NC}  %s\n" "${target}"
		elif [ -L "$target" ]; then
			dest="$(readlink "$target" 2>/dev/null || true)"
			case "$dest" in
			"${CONFIG_ROOT}"/*)
				printf "  ${GREEN}[SYMLINK]${NC}  %s → %s\n" "${target}" "${dest}"
				;;
			*)
				printf "  ${YELLOW}[FOREIGN]${NC}  %s → %s\n" "${target}" "${dest}"
				;;
			esac
		else
			printf "  ${RED}[REGULAR]${NC}  %s  ← drift! was symlink, now regular file\n" "${target}"
			printf "  Run: setup restow %s   to re-link\n" "${module_ref}"
		fi
	done <"$mf"

	return 0
}

cmd_diff() {
	module_ref_arg="${1:-}"

	if [ -n "$module_ref_arg" ]; then
		module_ref="$(normalize_module_ref "$module_ref_arg")" || return 1
		_diff_one "$module_ref"
	else
		if [ ! -d "$MANIFEST_DIR" ] || [ -z "$(ls -A "$MANIFEST_DIR" 2>/dev/null)" ]; then
			info "No deployed modules found (manifest dir empty or absent)"
			return 0
		fi

		symlink_count=0
		foreign_count=0
		regular_count=0
		missing_count=0

		manifest_files="$(find "$MANIFEST_DIR" -maxdepth 1 -type f 2>/dev/null || true)"
		for mf in $manifest_files; do
			[ -z "$mf" ] && continue
			mf_base="$(basename "$mf")"
			module_ref="$(printf '%s' "$mf_base" | sed 's#__#/#g')"
			_diff_one "$module_ref"
			printf "\n"

			while IFS= read -r target; do
				[ -z "$target" ] && continue
				if [ ! -e "$target" ] && [ ! -L "$target" ]; then
					missing_count=$((missing_count + 1))
				elif [ -L "$target" ]; then
					dest="$(readlink "$target" 2>/dev/null || true)"
					case "$dest" in
					"${CONFIG_ROOT}"/*)
						symlink_count=$((symlink_count + 1))
						;;
					*)
						foreign_count=$((foreign_count + 1))
						;;
					esac
				else
					regular_count=$((regular_count + 1))
				fi
			done <"$mf"
		done

		info "Diff: ${symlink_count} symlinks, ${regular_count} drift (regular), ${foreign_count} foreign, ${missing_count} missing"
	fi
}

main() {
	cmd="${1:-}"
	case "$cmd" in
	use)
		shift
		module_ref="${1:-}"
		[ -z "$module_ref" ] && usage
		module_ref="$(normalize_module_ref "$module_ref")" || exit 1
		symlink_module "$module_ref" && validate_module "$module_ref"
		;;
	profile)
		shift
		name="${1:-}"
		[ -z "$name" ] && {
			err "Expected profile name"
			usage
		}
		deploy_profile "$name"
		;;
	restow)
		shift
		module_ref="${1:-}"
		[ -z "$module_ref" ] && usage
		restow_module "$module_ref"
		;;
	adopt)
		shift
		module_ref="${1:-}"
		[ -z "$module_ref" ] && usage
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
		sub="${1:-}"
		if [ "$sub" = "profile" ]; then
			name="${2:-}"
			[ -z "$name" ] && {
				err "Expected profile name"
				usage
			}
			undo_profile "$name"
		else
			[ -z "$sub" ] && usage
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
