# Getting started

## Which target am I?

| System | Command |
|---|---|
| Non-NixOS Linux | `home-manager switch --flake .#atalariq@x86_64-linux` |
| NixOS | import the NixOS module (see `docs/nixos.md`) |
| WSL | same as non-NixOS Linux (see `docs/wsl.md`) |
| macOS, standalone | `home-manager switch --flake .#atalariq@aarch64-darwin` |
| macOS, nix-darwin | see `docs/darwin.md` |

`atalariq` is the default in `flake.nix`; change `username` and `device` there
before the first switch. `device` is only a label (`heighliner` by default), not
the operating system hostname.

## Install Nix first

Use the Determinate Nix installer or the upstream installer. Then enable
flakes:

```sh
mkdir -p ~/.config/nix
printf 'experimental-features = nix-command flakes\n' >> ~/.config/nix/nix.conf
```

## Standalone Linux

```sh
git clone https://github.com/atalariq/dotfiles.git ~/Repos/dotfiles
cd ~/Repos/dotfiles
# edit username/device
home-manager switch --flake .#atalariq@x86_64-linux
```

The profile installs fish but does not change your login shell. On a machine you
own:

```sh
command -v fish || true
chsh -s "$(command -v fish)"
```

If `chsh` is not available or the account is managed by the lab, add fish to
your shell config or start it manually. The interactive bash init also hands
over to fish when it is present.

## macOS standalone

```sh
home-manager switch --flake .#atalariq@aarch64-darwin
```

Home Manager manages CLI tools and config under `~/.nix-profile`; it does not
touch Homebrew or `/Applications`. GUI applications remain your choice.

## WSL

See [wsl.md](wsl.md).
