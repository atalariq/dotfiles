# WSL

WSL is Linux: use the standalone Home Manager target.

```sh
# inside the WSL distro
nix run home-manager/master -- switch --flake .#atalariq@x86_64-linux
```

## systemd

Atuin's daemon is disabled by default, so the profile works without systemd.
If you want user services (gnupg, atuin daemon), enable systemd in WSL:

```ini
# /etc/wsl.conf
[boot]
systemd=true
```

Then restart WSL from PowerShell:

```powershell
wsl --shutdown
```

## Fish

`chsh` may not be available in every distro. Start `fish` manually, or add it to
`~/.bashrc`:

```sh
[ -z "$FISH_VERSION" ] && command -v fish >/dev/null && exec fish
```

## Clipboard and GUI

`wl-clipboard` is part of the Linux package floor, but WSL clipboard integration
depends on the Windows terminal. The terminal workflow itself (fish, nvim,
yazi, tmux) needs no GUI packages.
