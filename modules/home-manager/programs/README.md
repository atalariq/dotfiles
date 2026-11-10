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

- **Shared CLI packages** live in `modules/packages/cli.nix`. Edit that one list
  when every managed host should have the tool.
- **Host-only CLI packages** go in `hosts/<platform>/<host>/apps.nix` under
  `cli`. Use this for a tool one machine needs.
- **GUI packages** are installed by the host:
  - NixOS: `hosts/nixos/<host>/apps.nix` → `environment.systemPackages`.
  - macOS: `hosts/darwin/<host>/apps.nix` → `homebrew.casks`.
  - Standalone Home Manager and headless hosts: no GUI packages.
- GUI modules under `gui/` only write config (kitty, espanso), a service
  (zotero), or a profile bridge (brave-origin, obs-studio). They must not call
  `home.packages` for the application itself. Native modules use
  `programs.<pname>.package = lib.mkForce null` when the host owns the binary.
- Native Home Manager modules (`programs.fd`, `programs.git`, ...) and
  config-bearing CLI modules (`btop`, `fastfetch`, `gh`, `aria2`, ...) install
  their own package; do not duplicate it in `apps.nix`.
- Rarely used tools (dust, duf, hyperfine, ...) stay out of the profile. Run
  them on demand with `comma` or `nix shell`.

## Where to edit

| I want to... | Edit |
| --- | --- |
| add a CLI tool for every host | `modules/packages/cli.nix` |
| add a CLI tool for one host | `hosts/<platform>/<host>/apps.nix` → `cli` |
| add a NixOS GUI application | `hosts/nixos/<host>/apps.nix` → `gui` |
| add a macOS application | `hosts/darwin/<host>/apps.nix` → `casks` |
| add a tool with native config | new `programs/<category>/<pname>.nix`, enable it in the host `home.nix` |

## Adding something

1. **Package only** — add the name to `modules/packages/cli.nix` (shared) or
   `hosts/.../apps.nix` (`gui` or `cli`). No new module.
2. **Needs configuration/service** — add `programs/<category>/<pname>.nix`
   with an `enable` option that defaults to `false`, then select it on the
   host. Put native files under `programs/<category>/config/<pname>/`.
3. **Shared data** — use `modules/packages/ides.nix` for the stack→IDE map.

Proprietary, account-bearing or state-bearing apps stay opt-in. Core bundles
must be free, headless-safe and credential-free.
