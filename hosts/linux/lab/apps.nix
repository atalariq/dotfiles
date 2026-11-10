# Standalone Home Manager host: CLI only, no GUI packages (GUI is host-owned
# and this host has no system layer to own it).
_: {
  stacks = [ ];
  # Shared CLI floor comes from modules/packages/cli.nix.
  cli = [ ];
}
