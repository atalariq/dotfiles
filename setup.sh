#!/usr/bin/env bash

TARGET="${HOME}"
# Get absoulte path for this dotfiles' directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

LAB_APPS=("bat" "fish" "nvim" "yazi")

PERSONAL_APPS=("${LAB_APPS[@]}" "aria2" "espanso" "glow" "htop" "lazygit" "kitty" "mpd" "mpv" "yt-dlp")
PERSONAL_DESKTOP=("niri")
PERSONAL_MISC=("fonts" "scripts" "startpage")
PERSONAL_SYSTEM="archlinux" # archlinux|mac

stow_folder() {
  local parent_dir=$1
  shift
  local items=("$@")

  for item in "${items[@]}"; do
    if [[ -d "$DOTFILES_DIR/$parent_dir/$item" ]]; then
      echo "Stowing $parent_dir/$item..."
      stow -R -d "$DOTFILES_DIR/$parent_dir" -t "$TARGET" "$item"
    else
      echo "Warning: $parent_dir/$item not found."
    fi
  done
}

case "$1" in
"lab")
  echo "Preparing profile for lab..."
  stow_folder "app" "${LAB_APPS[@]}"
  ;;
"personal")
  echo "Preparing profile for personal device..."
  stow_folder "app" "${PERSONAL_APPS[@]}"
  stow_folder "desktop" "${PERSONAL_DESKTOP[@]}"
  stow_folder "misc" "${PERSONAL_MISC[@]}"
  stow_folder "system" "$PERSONAL_SYSTEM"
  ;;
*)
  echo "Usage: $0 {lab|personal}"
  echo 'or manually using `stow -R -d "$DOTFILES_DIR/$parent_dir" -t "$TARGET" "$item"`'
  exit 1
  ;;
esac

echo "Done!"
