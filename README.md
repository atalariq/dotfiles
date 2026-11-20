# dotfiles

Terminal-first dotfiles for NixOS, generic Linux, macOS, and WSL.

This repository is the **public framework**: it contains the reusable Home
Manager and NixOS modules for my terminal workflow — fish, starship, Atuin,
Neovim (nvf), yazi, tmux, lazygit, btop, fastfetch, gh, git, helix, typst, and
yt-dlp.
It contains **no secrets and no private host inventory**.

The Dune names are examples: `caladan` is the generic NixOS example, `ix` the
generic nix-darwin example, and `heighliner` the default device label for
standalone Home Manager. Change them for your own machines.

## Quick start

Standalone Home Manager (non-NixOS Linux, WSL, or macOS):

```sh
# 1. Edit username and device at the top of flake.nix.
# 2. Switch:
nix run home-manager/master -- switch --flake .#atalariq@x86_64-linux
```

On macOS use `.#atalariq@aarch64-darwin`; on WSL keep the Linux system name.

NixOS: import `nixosModules.default` and `homeManagerModules.default` into your
own flake, or copy `hosts/example-nixos`. nix-darwin: copy
`hosts/example-darwin`.

## What is here

| Path | Purpose |
|---|---|
| `modules/home-manager` | terminal profile, identity, deployment modes |
| `modules/nvf` | shared Neovim kernel |
| `modules/stylix` | Gruvbox palette for kitty, nvim, starship, tmux |
| `modules/nixos` | small generic NixOS baseline |
| `modules/darwin` | nix-darwin defaults |
| `home/example.nix` | the profile every example uses |
| `hosts/example-*` | generic NixOS and Darwin hosts |
| `templates/default` | `nix flake init -t` template |

## Design rules

- No secrets, age keys, private domains, or host inventory in this repository.
- Platform-neutral modules; hosts own identity and hardware.
- `dotfiles.identity.username` and `dotfiles.identity.device` are variables,
  not constants.
- `dotfiles.deployment.mode = "immutable"` is the default; live mode is opt-in.

See [docs/getting-started.md](docs/getting-started.md) and
[docs/customizing.md](docs/customizing.md).

## License

MIT. See [LICENSE](LICENSE).
