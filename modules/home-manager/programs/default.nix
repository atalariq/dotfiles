{ lib, ... }:
{
  # Only immediate public modules are discovered, in deterministic name order.
  # Private runtime assets start with an underscore and never become imports.
  imports = lib.concatMap (
    name:
    let
      kind = (builtins.readDir ./.).${name};
    in
    if name == "default.nix" || lib.hasPrefix "_" name then
      [ ]
    else if kind == "directory" && builtins.pathExists (./. + "/${name}/default.nix") then
      [ (./. + "/${name}") ]
    else if kind == "regular" && lib.hasSuffix ".nix" name then
      [ (./. + "/${name}") ]
    else
      [ ]
  ) (builtins.attrNames (builtins.readDir ./.));
}
