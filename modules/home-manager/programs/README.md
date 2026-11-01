# Program modules

Four categories, one owner rule:

| Category | Option prefix | Core |
| --- | --- | --- |
| `agentic` | `dotfiles.programs.agentic.*` | terminal-only agent floor |
| `cli` | `dotfiles.programs.cli.*` | shell, git, Nix, vim, tmux, POSIX tools |
| `gui` | `dotfiles.programs.gui.*` | none; GUI is host-local |
| `development` | `dotfiles.programs.development.*` | `stacks` toolchain only |

## Layout

```text
<category>/default.nix       category core or host-local stub
<category>/<pname>.nix       one opt-in package module
<category>/_*.nix            helper imported explicitly; never a package
<category>/config/<pname>/   native configuration for <pname>
```

`<category>/default.nix` imports every sibling module through
`../_import-category.nix`; adding `<pname>.nix` exposes its option without
editing a registry. The top-level `programs/default.nix` imports only
categories.

## Option rules

- Every package module exposes `dotfiles.programs.<category>.<pname>.enable`
  (default `false`) and, for package-only modules, a `package` override.
- Category `enable` gates **core only**. Explicit per-package switches remain
  independent.
- Native Home Manager modules keep their own `programs.<pname>.package`; do not
  duplicate it.
- GUI has no global `enable`: select Nix-managed apps on NixOS, Homebrew casks
  on macOS, and nothing on headless hosts. `gui/workstation.nix` is only an
  aggregate for the NixOS workstation.
- Proprietary, account-bearing or state-bearing apps stay opt-in and carry an
  `# opt-in:` header. Core must be free, headless-safe and credential-free.

## Add a package

```nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.programs.cli.foo;
in
{
  options.dotfiles.programs.cli.foo = {
    enable = lib.mkEnableOption "foo";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.foo;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
```

Create `cli/foo.nix`, add `dotfiles.programs.cli.foo.enable = true;` on the
hosts that want it, and put native files under `cli/config/foo/` when needed.
Removing the module removes the option; hosts still referencing it fail
evaluation on purpose.
