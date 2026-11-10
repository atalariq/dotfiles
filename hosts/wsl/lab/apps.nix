# Standalone Home Manager host (WSL): CLI only, no GUI packages.
_: {
  stacks = [
    "node"
    "python"
  ];
  # Shared CLI floor comes from modules/packages/cli.nix.
  cli = [ ];
}
