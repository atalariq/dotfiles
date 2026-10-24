# Architectural decisions

These are decisions for this configuration's current design. They do not claim
to reconstruct undocumented historical motivations. The owner selected these
tradeoffs during the October 2026 redesign.

## Explicit feature selection

**Need:** understand and change a machine manually without discovering packages
or services hidden in broad imports.

**Choice:** all reusable features default to false. Hosts choose each feature;
groups organise source rather than activate a preset. Required companion
features are stated in assertions. A command's executable dependencies stay in
its wrapper's PATH.

**Alternative:** role profiles that enable many applications at once. They reduce
repetition but make the installed environment less apparent from host source.
The explicit lists are intentional and can differ between workstation and server.

References: [Calsjunior](https://github.com/Calsjunior/dotfiles),
[Foundry](https://github.com/Misterio77/Foundry),
[Waldir Borba](https://github.com/waldirborbajr/nixos-config).

## Native source with explanations

**Need:** preserve why a choice exists while keeping the files convenient to edit
with standard Nix, Lua, Fish and Vim tooling.

**Choice:** narrative comments in native source, short decisions here, and task
status in the backlog. Source is authoritative for behaviour.

**Alternative:** Org/Markdown code blocks tangled into configuration, as in
[natsukium's configuration](https://github.com/natsukium/dotfiles). That provides
an integrated reading experience but adds generation and synchronisation steps.
This repository deliberately keeps those steps out of ordinary maintenance.

## Mango, Noctalia and Stylix

Keep the existing compositor and keybinding workflow. Stylix is the source of
appearance values; Noctalia consumes that palette and does not generate colours.
Home Manager specialisations provide prebuilt Gruvbox dark/light variants. A
stable base-generation catalogue and saved selection allow repeated switching
and restoration without a system rebuild. Application package sets are identical
between variants. [Appearance details](themes.md).

## Neovim through nvf; independent Vim for servers

**Need:** build the workstation editor, plugins, parsers and external tools as a
single package that can be tested before installation. Retain the established
keymaps, plugin settings, snippets and language workflows.

**Choice:** nvf composes the package, Nixpkgs supplies packaged plugins and parsers,
and existing Lua defines behaviour. Plugins absent from Nixpkgs use explicit
flake source pins. Both `nix run .#neovim` and HM use the same immutable package.

**Alternative:** Lua with vim.pack permits a short edit/reload loop, but plugin and
parser bootstrap adds mutable machine state outside the system generation. nvf
moves that ownership to builds at the cost of rebuilding for dependency changes.
It does not require translating every plugin setup into a framework option.

Vim is an independent daily editor for server work, not an alias or a degraded
Neovim. It uses buffers, netrw, grep, make, quickfix and diff without external
plugins. A copied vimrc works offline without Nix, a package bootstrap or a font
installation. Neovim remains the workstation editor; use `vim` explicitly or set
EDITOR/GIT_EDITOR on a server.

Reference: [nvf](https://nvf.notashelf.dev/).

## Immutable deployment and explicit live development

Immutable native files follow generations and are the default. Live checkout
links shorten native configuration iteration but require Git to undo edits.
Neither mode makes runtime databases, authentication sessions or generated colour
fragments immutable. See [source modes](configuration.md#source-modes).

## Minimal devShells and explicit services

Independent flakes under `devshell/` provide only core tooling. direnv uses
nix-direnv caching with reviewed `.envrc` files. Splitting vanilla/Bun/Node/PHP
avoids installing an unrelated toolchain for every web project. Containers and
services are confined to `bun-with-services`, with optional database and metrics
profiles, loopback ports and retained volumes. [Development guide](development.md).

## sops-nix for secret delivery

**Need:** reuse encrypted SOPS/age sources without exposing every API key to every
interactive command.

**Choice:** sops-nix materialises only declared secrets as private runtime files.
Application wrappers read their declared values immediately before launching the
consumer. The parent shell receives no decrypted exports.

**Alternatives:** agenix uses a different encrypted-file convention; SecretSpec
adds provider-independent application resolution. The owner chose sops-nix alone
to keep one integration and reuse existing encrypted sources. Runtime wrappers
reduce accidental delivery; they are not a sandbox against a process that can
access the same user's keys or runtime files.

Reference: [sops-nix](https://github.com/Mic92/sops-nix).

## Device identity and balanced power

The host is named `thinkpad-x13`; its hardware metadata records the Gen 2a AMD
model. Directory, primary output and hostname agree. The former output alias and host directory have been removed.

Preserve generated hardware, disk identities and stateVersion. Keep one power
policy manager, power-profiles-daemon, and measure battery, temperature and
suspend/resume before introducing kernel parameters or alternative managers.
The generic upstream X13 AMD profile is a reference, not evidence that a specific
tweak is needed on this Gen 2a device.
