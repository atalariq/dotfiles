# Standalone Home Manager host (WSL): CLI only, no GUI packages.
{ pkgs }:
let
  common = import ../../../modules/packages/common.nix { inherit pkgs; };
in
{
  stacks = [
    "node"
    "python"
  ];
  cli = common.cli;
}
