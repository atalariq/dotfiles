# ADR-0003: Consolidate deployable modules under `config/`

Status: Accepted

## Context

Deployable dotfiles used to live in four top-level roots: `app/`, `desktop/`, `misc/`, and `system/`. That worked, but it made the repo look split-brain because non-deployable top-level directories like `docs/` and `profiles/` sat beside them with equal visual weight.

The old profile schema also mirrored those buckets directly:
- `apps`
- `desktop`
- `misc`
- `system`

That forced both `setup.sh` and `bootstrap.sh` to duplicate the same deployment loop four times and required `jq` just to expand a profile.

## Decision

1. Move all deployable modules under a single top-level `config/` directory.
2. Keep the internal category grouping under that root:
   - `config/app/`
   - `config/desktop/`
   - `config/misc/`
   - `config/system/`
3. Keep CLI module references as `<category>/<module>` for ergonomics and backwards compatibility.
4. Flatten profile files to a single `modules` array.
5. Replace `jq`-based profile parsing with Python stdlib JSON parsing.
6. Do not adopt Ansible at this stage.

## Consequences

### Good
- Repo structure is easier to scan.
- Deployable config is visually separate from docs, plans, and metadata.
- Profile parsing is simpler.
- Bootstrap logic becomes module-centric instead of category-centric.
- One external dependency (`jq`) is removed from the bootstrap path.

### Bad
- Source paths in docs and historical notes must be updated.
- The public CLI syntax (`app/fish`) no longer exactly matches the physical repo path (`config/app/fish`).
- Python 3 becomes a required bootstrap dependency.

## Rejected alternatives

### Keep the old top-level layout
Rejected because it preserved duplication and kept the repo harder to scan.

### Switch to Ansible now
Rejected because the repo's primary need is deterministic symlink deployment, not full-machine orchestration. Ansible would add another abstraction layer, more files, and more maintenance cost before the current bootstrap approach is even cleaned up.

If machine provisioning grows much wider later, revisit a hybrid approach. For now, the custom bootstrap is the cheaper and clearer tool.
