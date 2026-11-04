# Agentic tools

Every agent-related switch lives in the `dotfiles.programs.agentic.<name>.enable`
namespace. Hosts select explicitly; enabling something never installs a client
another host has not chosen.

## The core

`dotfiles.programs.agentic.core.enable` installs the set that should run on every
host that runs agents - it lives directly in `default.nix` (the group kernel),
not in per-tool modules:

- **Beads Rust** (`br`) and **Beads Viewer** (`bv`) - task queue and its
  graph-aware TUI;
- **CodeGraph** - the shared code-intelligence MCP server;
- **Crit** - inline review of what an agent produced;
- **RTK** - compaction for noisy command output;
- **Tirith** - policy lint for shell/agent actions;
- **Tokscale** - local AI token-usage tracking.

All of them are terminal-only and need no browser or display, so headless hosts
and future servers keep the same floor. The core is deliberately atomic: to drop
one member later, extract it back into its own module rather than adding a flag
per tool now.

The clients (`codex`, `claude`, `opencode`, `hermes`) and the remaining helper
(`agent-browser`) keep their own modules and stay individually opt-in - not
every host (or subscription) wants them. The trial bundle
(`experimental.enable`) is deliberately small: `luvus`, `openresearch` and
`tuicr`.

## CodeGraph

The module installs the pinned native CLI. Selected agent clients register its
MCP command separately. Installation does not index a project.

This repository's `codegraph.json` excludes task receipts, secrets, caches,
generated output and private runtime data. Review that policy before explicitly
running `codegraph init --yes .`. Keep `.codegraph/` local and ignored. Other
repositories need their own policy; this is not a machine-wide exclusion rule.

The native Nix extractor can find declarations and functions and resolve literal
relative imports. It does not evaluate the Nix module system: dynamic imports,
`mkMerge`/`mkIf` results, host overrides and effective option values still need
source inspection and `nix eval`. A symbol match is not proof of an effective
configuration value. Use native query/explore output alongside that validation.
