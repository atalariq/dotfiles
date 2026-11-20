# Customizing

## Identity

```nix
dotfiles.identity.username = "atalariq";
dotfiles.identity.fullName = "Atalariq Barra Hadinugraha";
dotfiles.identity.email = "atalariq.dev@outlook.com";
dotfiles.identity.device = "heighliner";
```

`username` must match the login account. `device` only labels the prompt and
`DOTFILES_HOST`; it never changes the OS hostname.

## Turning features on

The examples enable the terminal profile. Every feature is still an option:

```nix
dotfiles.programs.cli.neovim.profile = "full"; # LSPs, formatters, linters
dotfiles.programs.cli.helix.enable = true;
dotfiles.programs.cli.yazi.enable = true;
dotfiles.programs.cli.atuin.enable = true;
dotfiles.programs.gui.kitty.enable = true;    # config only; install the binary
dotfiles.programs.development.direnv.enable = true;
dotfiles.appearance.enable = true;            # Stylix / Gruvbox
dotfiles.appearance.gui = false;              # no GTK/Qt targets on headless
```

## Live mode

`dotfiles.deployment.mode = "live"` links native config to the checkout so edits
apply without a rebuild. Generated files (themes, plugin lists) still need a
rebuild. The checkout must stay inside your home directory:

```nix
dotfiles.deployment.mode = "live";
dotfiles.deployment.checkout = "/home/you/Repos/dotfiles";
```

## Adding tools

- Cross-platform CLI package: `modules/packages/cli.nix`.
- Tool that needs configuration or a service: a module under
  `modules/home-manager/programs/<category>/`.
- Host-only GUI application: your host's package list, not this repository.

## No secrets

This repository intentionally has no `secrets/` directory and no `.sops.yaml`.
Keep credentials in your own private repository or in the platform keychain.
