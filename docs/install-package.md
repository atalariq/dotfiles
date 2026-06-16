# Package Installation

Reference snapshot of explicitly-installed packages on this machine. Not a
blind bootstrap — install what a given machine actually needs.

## Minimal base (for bootstrap)

```bash
sudo pacman -Syu --needed git bash python fish neovim
```

## Native (pacman, explicit)

226 packages as of 2026-06-17.

```bash
sudo pacman -S --needed \
  7zip accountsservice adw-gtk-theme alacritty anki aria2 astyle atuin \
  base base-devel bash-language-server bat biome bluetui bluez \
  bluez-deprecated-tools bluez-utils brightnessctl btop bun cava ccache \
  cliphist cloudflare-speed-cli cmake d2 ddcutil delve dnscrypt-proxy \
  docker docker-buildx docker-compose dockerfile-language-server dua-cli duf \
  dust efibootmgr eslint-language-server ethtool evtest eza fastfetch fbset \
  fd fish fvm fyi fzf ghostscript git git-delta git-filter-repo git-lfs \
  github-cli gitlab-ci-ls gitleaks gitoxide glab glow gnome-tweaks go \
  gofumpt golangci-lint gpu-screen-recorder gtk-layer-shell gvfs htop \
  hyperfine imagemagick impala imv intel-gpu-tools intel-media-driver \
  intel-ucode inter-font inxi iwd jdk21-openjdk jemalloc jless jpegoptim jq \
  just just-lsp kdeconnect kitty kotlin ktlint lazygit less lib32-gamemode \
  lib32-mesa libnotify libpulse libreoffice-fresh libva-intel-driver \
  libwebp-utils linux-firmware linux-firmware-intel linux-zen \
  linux-zen-headers lldb lua-language-server mado man-db marksman maven \
  mdfried mediainfo mise mpc mpd mpv mpv-mpris nautilus neovim nicotine+ \
  noto-fonts-cjk noto-fonts-emoji ntfs-3g nvtop obs-studio openai-codex \
  opencode openssh oxipng pacman-contrib papirus-icon-theme pavucontrol \
  perl-image-exiftool pgformatter php pipewire pipewire-alsa pipewire-jack \
  pipewire-pulse pkgfile polkit-gnome prettier procs profile-cleaner psutils \
  python-matplotlib python-numpy python-pipx qutebrowser reflector ripgrep \
  rmpc rst2pdf rsync ruff rumdl rustup satty selene shfmt showmethekey \
  smartmontools sops sqlfluff starship stylua systemd-lsp \
  tailwindcss-language-server tealdeer terminus-font tesseract-data-eng \
  tesseract-data-ind texlab time tinymist tlp tlp-pd tmux tokei tombi tree \
  tree-sitter-cli ttf-fira-code ttf-nerd-fonts-symbols \
  ttf-nerd-fonts-symbols-common ttf-nerd-fonts-symbols-mono ty typos \
  typos-lsp typst typstyle ufw unzip uv vale vscode-css-languageserver \
  vscode-html-languageserver vscode-json-languageserver vulkan-intel waycheck \
  wayland-protocols wayland-utils websocat wev wget wireless_tools wireplumber \
  wl-clip-persist wl-clipboard wl-mirror wlr-randr wtype wxwidgets-gtk3 \
  xdg-desktop-portal-wlr xdg-utils xorg-xrdb xorg-xwayland \
  xwayland-satellite yaml-language-server yamlfmt yamllint yazi yq yt-dlp \
  zathura zathura-pdf-mupdf zip zoxide zram-generator
```

## AUR (yay, explicit)

44 packages as of 2026-06-17.

```bash
yay -S --needed \
  basedpyright-bin beekeeper-studio-bin brave-bin detekt-bin facetimehd-data \
  facetimehd-dkms facetimehd-firmware google-breakpad google-chrome \
  google-cloud-cli google-cloud-cli-gsutil google-java-format hadolint-bin \
  helium-browser-bin herdr-bin jdtls kanata-bin kbdlight kotlin-lsp-bin \
  lazysql lyricspot macbook-12-1-linux-fixes mangowm mbpfan-git mpdris2-rs \
  noctalia-git phpactor-bin postgres-language-server-bin python-unoserver \
  python-yams qt6ct-kde ripdrag-git rtk-bin shellcheck-bin sqls-bin tableplus \
  tirith usql ventoy-bin vscode-js-debug vtsls wakadash-bin webcord-bin wlrctl \
  yay-bin
```

Regenerate with `pacman -Qqen` / `pacman -Qqem`.
