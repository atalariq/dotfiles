# ADR-0001: Validated Symlink Farm replaces GNU Stow

Status: Accepted

## Context

Currently `setup.sh` delegates to `stow -R` for symlink deployment. Stow is an external dependency with no testability — no way to verify configs are valid after deployment, no manifest for rollback, and no per-module validation.

## Decision

Replace GNU Stow with a **validated symlink farm** implemented as a bootstrap script with three subcommands:

- `bootstrap use <category/module>` — deploy a single module directly
- `bootstrap profile <name>` — deploy all modules declared in a JSON profile
- `bootstrap undo <category/module>` — rollback a module by reading the manifest

### Conflict detection

**Interactive.** When a target path already exists (and is not a symlink in our manifest), prompt: `skip` / `overwrite` / `backup` (move to `.bak`).

### Validation

**Per-module.** After symlinking each module, run validation immediately:
- Symlinks resolve to real files
- Config files parse without errors (kitty.conf, mango .conf, niri .kdl)
- Scripts have valid shebangs and are executable
- Secrets (`secrets.yaml`) decrypt successfully via `sops`

Most modules are linked file-by-file. A module may declare a scoped directory-level symlink for a subtree that is intentionally managed as one unit. `misc/scripts` uses that for `~/.local/script` while keeping the same conflict handling and manifest-based rollback.

Failures halt the deploy for that module only — other modules continue.

### Rollback

- **Manifest-driven.** Every `bootstrap use` and `bootstrap profile` writes symlink paths to module-specific manifest files under `~/.local/state/bootstrap/manifests/`. `bootstrap undo` reads the matching manifest and removes the listed symlinks.

## Consequences

- **Removes** GNU Stow as a dependency (replaced by `ln -s` + bash logic)
- **Adds** test surface: bootstrap operations are testable through the manifest and validation output
- **Adds** manifest state directory: `~/.local/state/bootstrap/manifests/`
- **Adds** `python3` as required dependency (for profile parsing and JSON validation)
- `setup.sh` becomes a thin wrapper that calls `bootstrap profile <name>`
