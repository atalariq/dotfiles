#!/usr/bin/env bash
# Child-shell expressions are intentionally evaluated by the child.
# shellcheck disable=SC2016
set -euo pipefail
provider=$1
fish_hook=$2
bash_init=$3
root=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
work=$(mktemp -d)
trap 'rm -rf -- "$work"' EXIT
export HOME="$work/home" XDG_CONFIG_HOME="$work/home/.config" XDG_STATE_HOME="$work/home/.local/state" XDG_DATA_HOME="$work/home/.local/share" XDG_CACHE_HOME="$work/home/.cache"
mkdir -p "$XDG_CONFIG_HOME/direnv" "$work/outside"
printf 'source %q\n' "$provider/share/nix-direnv/direnvrc" > "$XDG_CONFIG_HOME/direnv/direnvrc"
cp -R "$root/devshell/go" "$work/project"
printf 'export DOTFILES_DIRENV_PROBE=loaded\n' >> "$work/project/.envrc"
export PROJECT="$work/project" OUTSIDE="$work/outside" FISH_HOOK="$fish_hook" BASH_INIT="$bash_init"
direnv allow "$PROJECT"
bash --noprofile --norc -c '
  source "$BASH_INIT"
  cd "$PROJECT"; _direnv_hook
  test "$DOTFILES_DIRENV_PROBE" = loaded
  go version
  cd "$OUTSIDE"; _direnv_hook
  test -z "${DOTFILES_DIRENV_PROBE+x}"
'
fish --no-config --interactive --command '
  source "$FISH_HOOK"
  cd "$PROJECT"; emit fish_prompt
  test "$DOTFILES_DIRENV_PROBE" = loaded; or exit 1
  cd "$OUTSIDE"; emit fish_prompt
  not set -q DOTFILES_DIRENV_PROBE; or exit 1
'
printf 'Real Bash/Fish direnv entry, cached flake environment and unload passed.\n'
