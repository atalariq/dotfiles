# CodeGraph

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
