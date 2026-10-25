#!/bin/sh
# Publish an inventory only after every scan/read has succeeded.
set -eu
generation=${1:?Usage: audit-home.sh GENERATION [HOME]}
target_home=${2:-$HOME}
files=$(readlink -f -- "$generation/home-files")
[ -d "$files" ] && [ -d "$target_home" ] || exit 1
umask 077
work=$(mktemp -d)
trap 'rm -rf -- "$work"' EXIT HUP INT TERM
if ! find "$files" \( -type f -o -type l \) -exec sh -c '
  set -eu
  files=$1; target_home=$2; shift 2
  tab=$(printf "\t")
  newline="
"
  for source do
    relative=${source#"$files"/}
    case "$relative$target_home" in *"$tab"*|*"$newline"*)
      echo "Inventory paths cannot contain tabs or newlines" >&2; exit 1 ;;
    esac
    target=$target_home/$relative
    parent=${target%/*}
    while :; do
      if [ -d "$parent" ] && [ ! -x "$parent" ]; then
        printf "Cannot inspect directory: %s\n" "$parent" >&2; exit 1
      fi
      if [ -L "$parent" ]; then
        link=$(readlink -- "$parent")
        printf "parent-link\t%s\t%s\n" "$parent" "$link"
      fi
      [ "$parent" != "$target_home" ] && [ "$parent" != / ] || break
      parent=${parent%/*}
    done
    if [ -L "$target" ]; then
      link=$(readlink -- "$target")
      case "$link" in /nix/store/*-home-manager-files/*) kind=managed-link ;; *) kind=foreign-link ;; esac
      [ -e "$target" ] || kind=dangling-link
      printf "%s\t%s\t%s\n" "$kind" "$target" "$link"
    elif [ -e "$target" ]; then
      kind=conflict
      if [ -f "$source" ] && [ -f "$target" ]; then
        if cmp -s -- "$source" "$target"; then kind=identical
        else
          status=$?
          [ "$status" = 1 ] || { printf "Cannot compare: %s\n" "$target" >&2; exit "$status"; }
        fi
      fi
      printf "%s\t%s\t-\n" "$kind" "$target"
    else printf "absent\t%s\t-\n" "$target"; fi
  done
' sh "$files" "$target_home" {} + >"$work/raw"; then
	echo 'HOME audit failed; no inventory published.' >&2
	exit 1
fi
if [ -L "$target_home/.config/nvim" ]; then
	link=$(readlink -- "$target_home/.config/nvim")
	printf 'legacy-neovim-link\t%s\t%s\n' "$target_home/.config/nvim" "$link" >>"$work/raw"
fi
sort -u "$work/raw" >"$work/sorted"
cat "$work/sorted"
