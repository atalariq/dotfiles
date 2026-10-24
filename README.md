<div align="center">

# Dotfiles

**A personal workspace, expressed in Nix.**

Mango · Noctalia · Stylix · Gruvbox · Fish · Neovim · Vim

[About](#about) · [Structure](#layoutstructure) · [Install](#install--apply) · [Reference](#quick-references) · [Notes](#notes)

![Desktop screenshot placeholder — replace after desktop acceptance](docs/assets/desktop-placeholder.svg)

*Screenshot placeholder. This image is not a capture of the running desktop.*

</div>

## About

A modular NixOS and Home Manager configuration for a ThinkPad workstation and a
portable Linux command-line environment. Each application and system feature is
opt-in. Hosts describe their choices; reusable modules describe how those choices
work. Comments explain decisions close to their implementation, with longer
explanations in [the architecture notes](docs/decisions.md).

The workstation combines Mango's tiling workflow with Noctalia's desktop shell
and Stylix-managed Gruvbox themes. Neovim is built through nvf; Vim provides an independent,
plugin-free server workflow. Project tools live in flake devShells, with direnv integration. The specialised Bun template provides optional Podman services.

This is a personal configuration intended to be read and adapted. Supporting a
new machine means defining its hardware, user identity and explicit feature set.

## Layout/Structure

```text
flake.nix                        Inputs, hosts, packages, checks and templates
hosts/nixos/thinkpad-x13/         Host identity and preserved device configuration
profiles/                        Portable Home Manager feature selection
modules/nixos/                   Explicit system features
modules/home-manager/            Independent applications grouped by purpose
packages/neovim/                 Shared standalone/HM nvf editor package
lib/                             Native-source and runtime-command helpers
devshell/                        Twelve minimal, independent flake templates
themes/                          Stylix scheme registry and shared appearance
tests/                           Isolation, editor, theme and service checks
docs/                            Guides, decisions and validation records
secrets/                         Encrypted SOPS data; keys stay outside Git
```

Applications are grouped by purpose: terminal, editors, development, desktop,
agents, downloader, working, academic, media, security and gaming. Importing a
group enables none of its features. Simple package modules use a single Nix file;
configured applications own their native sources and runtime helpers. There are
no compatibility directories or old host aliases.

## Prerequisites

- Nix with `nix-command` and `flakes` enabled, Git, and an internet connection for
  uncached inputs and build dependencies.
- NixOS for the workstation; Linux with Nix for standalone Home Manager.
- Your own hardware configuration, username and home directory when adapting the
  host. Do not reuse another machine's filesystem UUIDs or encryption settings.
- An age identity with access to your encrypted SOPS file if enabling secrets.
  Modules can be evaluated and built without decrypting credentials.
- Podman rootless is needed only for `bun-with-services`. Other templates have
  no container requirement and can be reproduced by matching tool versions.

## Install & Apply

Clone or fork this repository into a directory of your choice. Review the host
and user configuration before applying it. For a new machine, follow
[adding a host](docs/installation.md#add-a-host) instead of using the ThinkPad's
hardware configuration.

From the repository root:

```sh
nix flake check
nix build .#nixosConfigurations.thinkpad-x13.config.system.build.toplevel --no-link
nix build .#homeConfigurations.portable.activationPackage --no-link
```

Nix Git flakes include tracked files. Add new public sources deliberately after
review; keep private keys, credentials and runtime state outside the index.
Review existing HOME targets and back up conflicts before the first activation.

On the configured ThinkPad, apply a reviewed build with:

```sh
sudo nixos-rebuild switch --flake .#thinkpad-x13
```

For another Linux machine, adapt `profiles/portable.nix` and its identity first, then:

```sh
nix run .#home-manager -- switch --flake .#portable
```

See [installation and recovery](docs/installation.md) for conflict handling,
rollback, secrets provisioning and first-use checks. Preserve the existing
`stateVersion` when adopting this layout on an established installation.

## Known Hosts

| Host | Platform | Device | Role |
| --- | --- | --- | --- |
| `thinkpad-x13` | `x86_64-linux`, NixOS | Lenovo ThinkPad X13 Gen 2a, AMD Ryzen 7 PRO 5850U | Personal workstation |
| `portable` | `x86_64-linux`, Home Manager | User-selected Linux machine | CLI and editor environment |

The sole NixOS host output and hostname are `thinkpad-x13`.

## Quick References

| Task | Command or source |
| --- | --- |
| Select features | host `home.nix`, `profiles/portable.nix`, host `default.nix` |
| Read module/deployment conventions | [Configuration guide](docs/configuration.md) |
| Try the shared editor | `nix run .#neovim` |
| Enter the maintenance environment | `nix develop`, or review `.envrc` and run `direnv allow` |
| Start a project environment | `nix flake init -t /path/to/dotfiles#python` |
| Available toolchains | [Minimal devShells](docs/development.md) |
| Change the prebuilt theme | `dotfiles-theme set gruvbox-light` |
| Theme/font details | [Appearance guide](docs/themes.md) |
| Run project services | `./services up postgres`, `up redis`, or `up observability` |
| Stop services, retain data | `./services down` |
| Run Hermes with scoped credentials | `hermes-with-secrets hermes` |
| Update one input deliberately | `nix flake update nixpkgs` |
| Format Nix sources | `nix fmt -- path/to/module.nix` |
| Read current work and future ideas | [Backlog](TODO.md) |

Project templates include [usage guides](docs/development.md), direnv integration
and recorded versions. Only `bun-with-services` includes Compose files. Creating a template does not install dependencies
or start a service until you invoke the corresponding command.

## Notes

- Native configuration uses immutable sources by default. Live mode is an
  explicit development choice; generation rollback cannot undo live edits.
- Writable state stays outside the repository: editor caches, application
  sessions, tokens, database volumes and the saved appearance selection.
- Plugin and parser installation belongs to the Nix editor build, never startup.
  Vim can be copied to a server independently of Nix and Neovim.
- Zotero has an independent module and remains disabled by default.
- The working group includes Plane/Linear web launchers and Slack desktop.
- Hermes runs interactively; no gateway service is enabled. OmniRoute waits for
  an explicitly provisioned immutable image pin before starting.
- SDK licenses, account enrollment and physical-device authorization are manual.
- Builds and automated checks do not establish runtime or device acceptance.

## Inspiration

[Ryan Yin](https://github.com/ryan4yin/nix-config) ·
[Misterio's starter configs](https://github.com/Misterio77/nix-starter-configs) ·
[Foundry](https://github.com/Misterio77/Foundry) ·
[Calsjunior](https://github.com/Calsjunior/dotfiles) ·
[natsukium](https://github.com/natsukium/dotfiles) ·
[Waldir Borba](https://github.com/waldirborbajr/nixos-config)

The architecture borrows explicit feature selection, readable composition and
reasoning alongside source. The configuration and its tradeoffs remain specific
to this repository. Licensed under [MIT](LICENSE).
