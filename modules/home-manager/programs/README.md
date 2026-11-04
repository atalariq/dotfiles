# Program modules

Four categories, one ownership rule:

| Category | Option prefix | Owner |
| --- | --- | --- |
| `agentic` | `dotfiles.programs.agentic.*` | Home Manager (terminal tools) |
| `cli` | `dotfiles.programs.cli.*` | Home Manager (config + packages) |
| `gui` | `dotfiles.programs.gui.*` | **system** package; Home Manager config only |
| `development` | `dotfiles.programs.development.*` | `stacks` toolchains (Home Manager) |

## Layout

```text
<category>/default.nix       category kernel (imports config-bearing modules)
<category>/<pname>.nix       a module that owns configuration or a service
<category>/_*.nix            helper imported explicitly; never a package
<category>/config/<pname>/   native configuration for <pname>
```

`<category>/default.nix` imports every sibling module through
`../_import-category.nix`. A file in this tree must justify itself with
configuration, a service, an assertion or a wrapper. Package-only entries do
**not** get a module.

## Package ownership

- **GUI packages** are installed by the host:
  - NixOS: `hosts/nixos/<host>/apps.nix` → `environment.systemPackages`.
  - macOS: `hosts/darwin/<host>/apps.nix` → `homebrew.casks`.
  - Standalone Home Manager and headless hosts: no GUI packages.
- GUI modules under `gui/` only write config (kitty, espanso), a service
  (zotero), or a profile bridge (brave-origin, obs-studio). They must not call
  `home.packages` for the application itself. Native modules use
  `programs.<pname>.package = lib.mkForce null` when the host owns the binary.
- **CLI packages** stay in Home Manager. The shared floor lives in
  `cli/default.nix`; host-specific extras go in `apps.nix` `cli` (NixOS/macOS)
  or `home.packages` (standalone).
- Native Home Manager modules (`programs.fd`, `programs.git`, ...) install
  their own package; do not duplicate it in `apps.nix`.

## Adding something

1. **Package only** — add the name to `hosts/.../apps.nix` (`gui` or `cli`) or
   to `home.packages` on a standalone host. No new file.
2. **Needs configuration/service** — add `programs/<category>/<pname>.nix`
   with an `enable` option that defaults to `false`, then select it on the
   host. Put native files under `programs/<category>/config/<pname>/`.
3. **Shared by several hosts** — put it in `modules/packages/common.nix` (or
   `ides.nix` for the stack→IDE data) and import it from the hosts that want
   it.

Proprietary, account-bearing or state-bearing apps stay opt-in. Core bundles
must be free, headless-safe and credential-free.
