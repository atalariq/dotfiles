# Standalone Home Manager host: CLI only, no GUI packages (GUI is host-owned
# and this host has no system layer to own it).
{ pkgs }:
let
  common = import ../../../modules/packages/common.nix { inherit pkgs; };
in
{
  stacks = [ ];
  cli = common.cli;
}
