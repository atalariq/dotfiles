# dotfiles
Place to backup my linux configurations

> DISCLAIMER!
> 
> This README is old, so many information is not relevant anymore. DWYOR!

## Info

- OS : Arch Linux
- Desktop Environment : GNOME
- Windows Manager : Hyprland
- Terminal Emulator : kitty
- Shell : bash (script) | fish (interactive)
- File Manager : Nautilus | yazi
- Media Player : mpv
- Music Player : Spotify | mpd/ncmpcpp
- Text Editor : Neovim
- Other Nice Apps : Obsidian | Anki | Koodo Reader

## Packages

Add `chaotic-aur` repository first: https://aur.chaotic.cx/

Then install `yay` or `paru` or any AUR Wrapper!
```bash
sudo pacman -S yay
```

### GNOME
```bash
yay -S gnome gdm \
  gnome-calculator gnome-calendar gnome-photos gnome-console \
  gnome-tweaks extension-manager-git \
  gnome-shell-extensions \
  gnome-shell-extension-appindicator \
  gnome-shell-extension-dash-to-dock \
  gnome-shell-extension-gsconnect \
  xdg-desktop-portal-gnome
```

### Hyprland
```bash
yay -S \
  hyprland-git \
  hypridle hyprlock \
  swww waybar \
  hyprpicker-git grimblast-git \
  dunst polkit-gnome \
  wdisplays kanshi \
  cliphist wl-clipboard \
  wofi rofi-lbonn-wayland \
  brightnessctl playerctl \
  swappy grim
```

### Applications

#### GUI
```bash
yay -S \
  google-chrome \
  obsidian anki \
  evince \
  libreoffice-still \
  mpv spotify \
  telegram-desktop element-desktop vesktop \
  nautilus nautilus-image-converter nautilus-sendto nautilus-share
```

#### CLI/TUI
```bash
yay -S \
  kitty \
  stow \
  neovim \
  yazi \
  lazygit \
  htop neofetch zoxide fzf glow \
  eza bat ripgrep fd \
  aria2c wget curl yt-dlp python-spotdl \
  mpd mpd-mpris mpc ncmpcpp \
  imagemagick ffmpeg pandoc-cli \
  alsa-utils brightnessctl playerctl \
```

#### Games
```bash
yay -S \
  itch-setup-bin \
  mcpelauncher-linux-git \
  osu-lazer
```

#### Fonts
```bash
yay -S \
  adobe-source-han-sans-cn-fonts adobe-source-han-sans-jp-fonts adobe-source-han-sans-kr-fonts \
  inter-font noto-fonts noto-fonts-emoji \
  ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-common ttf-nerd-fonts-symbols-mono
```

#### System
```bash
yay -S \
  android-tools android-udev \
  cups cups-filters cups-pk-helper gutenprint system-config-printer \
  pipewire pipewire-alsa wireplumber \
  xdg-utils xdg-user-dirs xdg-user-dirs-gtk xdg-desktop-portal \
  v4l2loopback-dkms v4l2loopback-utils v4l-utils \
  btrfs-progs grub-btrfs os-prober-btrfs \
  gvfs gvfs-afc gvfs-goa gvfs-google gvfs-gphoto2 gvfs-mtp gvfs-nfs gvfs-smb \
  nfs-utils ntfs-3g dosfstools \
  mesa-amber lib32-mesa-amber \
  intel-ucode intel-media-driver vulkan-intel lib32-vulkan-intel
```

