#!/usr/bin/env bash
# Exercise the actual theme command and base activation hook in an isolated HOME.
set -euo pipefail
command_source=$1
base_hook=$2
export HOME=/build/theme-home
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"
config="$XDG_CONFIG_HOME/dotfiles-theme"
state="$XDG_STATE_HOME/dotfiles/theme"
mkdir -p "$config" "$state" "$HOME/generation/specialisation"
printf '%s\n' '{"themes":["gruvbox-dark","gruvbox-light"],"default":"gruvbox-dark"}' > "$config/catalogue.json"
printf 'gruvbox-dark\n' > "$config/current"
for name in gruvbox-dark gruvbox-light; do
  mkdir -p "$HOME/generation/specialisation/$name"
  cat > "$HOME/generation/specialisation/$name/activate" <<'SCRIPT'
#!/bin/bash
set -euo pipefail
name=$(basename "$(dirname "$0")")
printf '%s\n' "$name" > "$XDG_CONFIG_HOME/dotfiles-theme/current"
printf '%s\n' "$name" > "$XDG_STATE_HOME/dotfiles/theme/selected"
SCRIPT
  # The Nix sandbox has no /bin/bash; use the actual shell interpreter.
  sed -i "1c#!$(command -v bash)" "$HOME/generation/specialisation/$name/activate"
  chmod +x "$HOME/generation/specialisation/$name/activate"
done
if bash "$command_source" set gruvbox-light; then echo 'Accepted missing base activation' >&2; exit 1; fi
bash "$base_hook" "$HOME/generation"
test "$(bash "$command_source" list | wc -l)" = 2
for name in gruvbox-light gruvbox-dark gruvbox-light; do
  bash "$command_source" set "$name"
  test "$(bash "$command_source" current)" = "$name"
done
# A new base deployment preserves the saved selection and the root catalogue.
printf 'gruvbox-dark\n' > "$config/current"
bash "$base_hook" "$HOME/generation"
test "$(bash "$command_source" current)" = gruvbox-light
test "$(readlink "$state/root")" = "$HOME/generation"
if bash "$command_source" set '../bad'; then echo 'Accepted unknown theme' >&2; exit 1; fi
test "$(bash "$command_source" current)" = gruvbox-light
printf 'retired-theme\n' > "$state/selected"
printf 'gruvbox-dark\n' > "$config/current"
bash "$base_hook" "$HOME/generation"
test "$(cat "$state/selected")" = gruvbox-dark
