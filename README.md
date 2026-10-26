# Dotfiles

NixOS, macOS, Linux, and WSL configurations with shared defaults and explicit
per-host choices. Native application configs live alongside the Nix modules
that install them.

[Hosts](#hosts) · [Setup](#setup) · [Customization](#customization) · [Development](#development)

## Features

- **Desktop:** Umbriel, a Mango fallback session, Noctalia, and the Look launcher.
- **Appearance:** Stylix themes, fonts, and application palettes.
- **Terminal:** Fish, Starship, Git, Tmux, Yazi, Vim, and Neovim configured through nvf.
- **Configuration:** Home Manager modules, immutable generations, and optional live editing of native files.
- **Secrets:** Application-scoped SOPS files with age identities provisioned separately.
- **Development:** Independent Bun, Go, and Rust flake templates; commands collected in a plain `Justfile`.

## Hosts

| Configuration | Platform | Manages |
| --- | --- | --- |
| `thinkpad-x13` | NixOS · x86_64 | System and Home Manager; Wayland desktop |
| `macpro-m4` | macOS · Apple Silicon | nix-darwin and Home Manager |
| `linux-lab` | Linux · x86_64 | Standalone Home Manager; command-line environment |
| `wsl-lab` | Ubuntu WSL2 · x86_64 | Standalone Home Manager; command-line environment |

The Linux and WSL lab configurations manage the user environment, not the host OS.
Darwin builds require a Mac or a Darwin builder.

## Setup

Install Nix with `nix-command` and `flakes` enabled, then clone this repository.
Adapt the username, home directory, Git identity, and host settings before use.
For NixOS, provide hardware and filesystem settings for the target machine.
New source files must be added to Git before they are included in a Git flake.

Enter the development shell and inspect the available commands:

```sh
nix develop
just --list
just check
```

Build the configuration for the target machine:

```sh
just build-thinkpad-x13
just build-macpro-m4
just build-linux-lab
just build-wsl-lab
```

Each command builds one host. Builds use `--no-link` and do not activate a
configuration. On an existing managed system, inspect the system closure changes
with `just diff-thinkpad-x13` or `just diff-macpro-m4`.

After reviewing the configuration and backing up conflicting files, run the
matching `just apply-<host>` recipe on its target machine. Inspect [Justfile](Justfile)
for the underlying commands. Home Manager activation can replace managed files
and restart user services.

### macOS bootstrap

Install Homebrew at its Apple Silicon prefix, `/opt/homebrew`, before activation.
For the first nix-darwin activation:

```sh
nix build .#darwinConfigurations.macpro-m4.system --no-link
sudo nix run --inputs-from . nix-darwin#darwin-rebuild -- switch --flake .#macpro-m4
```

Subsequent activations can use `just apply-macpro-m4`. If the Nix daemon is managed
by a separate installer, set `nix.enable = false` in the host configuration before
activation. Home Manager uses its built-in application integration; macOS may
request App Management permission for the terminal.

CLI tools, Kitty, and Pen come from Nix. The host also declares GUI applications
through Homebrew. Activation leaves unlisted Homebrew packages installed and does
not auto-update or upgrade them. Homebrew cask versions and application updaters
are outside the Nix lockfile.

### Linux and WSL

Install Nix in the existing distribution before applying `linux-lab` or `wsl-lab`.
User services such as sops-nix require systemd support; enable it in WSL when
using those services. The configuration does not provision Windows or a WSL distro.

## Customization

[Common defaults](modules/home-manager/common/default.nix) select the shared CLI
environment. Each host adds its own applications, system services, and displays.
Most application modules are opt-in; package definitions stay next to their consumers.

Override shared scalar defaults in the host's Home Manager module:

```nix
programs.fish.enable = false;
programs.git.settings.user.email = "you@example.com";
home.packages = [ pkgs.wget ]; # Adds to the shared package list.
# home.packages = lib.mkForce [ pkgs.git ]; # Replaces the entire package list.
```

Include `pkgs` and `lib` in the module arguments when using them. Keep each host's
`stateVersion` independent of package updates.

### Themes and native files

Select a theme with `dotfiles.appearance.theme` and rebuild. The default deployment
uses immutable sources. To edit supported native files directly, add this to a
Home Manager module with `config` in its arguments:

```nix
dotfiles.deployment = {
  mode = "live";
  checkout = "${config.home.homeDirectory}/.dotfiles";
  allowThemedFiles = true;
};
```

Set `checkout` to the actual repository location. Packages, plugins, and generated
theme files still require a rebuild. `allowThemedFiles` explicitly accepts that
limitation when live mode and appearance are enabled together.

### Secrets

Configure recipients in [.sops.yaml](.sops.yaml) and supply encrypted files using
[the secrets module](modules/home-manager/services/secrets.nix). Keep private age
identities outside the checkout and Nix store. The default identity location is
`~/.config/sops/age/keys.txt`; restrict the directory to `0700` and the file to `0600`.
Use separate device identities and retain a tested recovery recipient.

Select actual encrypted files before enabling secrets. Credentials are decrypted
at runtime rather than interpolated into Nix expressions. Treat dotenv files as
data, not executable shell. Application login state and private SSH/GPG keys remain
outside the repository.

## Development

| Location | Purpose |
| --- | --- |
| [hosts/](hosts/) | Platform, identity, application selection, and display settings |
| [modules/home-manager/](modules/home-manager/) | Shared defaults and application configuration |
| [modules/nixos/](modules/nixos/) | NixOS system integration |
| [modules/darwin/](modules/darwin/) | macOS system defaults |
| [modules/stylix/](modules/stylix/) | Theme palettes and adapters |
| [devshell/](devshell/) | Independent project templates |

Use `just fmt` to format Nix sources and `just check` to validate the flake and run
its checks for the current platform. Update dependencies deliberately with
`just update` or `just update nixpkgs`.

The [Bun](devshell/bun-with-services/README.md), [Go](devshell/go/README.md), and
[Rust](devshell/rust/README.md) templates include their own usage instructions.
Application-specific behavior is documented in the relevant module and native config.

## AI Usage Disclosure

Parts of this configuration and its documentation were developed with AI assistance,
including planning, implementation, and review. Design decisions and responsibility
for the published configuration remain with the maintainer. Successful builds and
automated checks do not imply activation or testing on physical hardware.

## Credits

Built with [Home Manager](https://github.com/nix-community/home-manager),
[nix-darwin](https://github.com/nix-darwin/nix-darwin),
[Stylix](https://github.com/nix-community/stylix),
[nvf](https://github.com/NotAShelf/nvf), and
[sops-nix](https://github.com/Mic92/sops-nix).

## License

[MIT](LICENSE)
