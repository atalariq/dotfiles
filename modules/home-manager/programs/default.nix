{ lib, ... }:
let
  entries = builtins.readDir ./.;
in
{
  imports = map (name: ./. + "/${name}") (
    builtins.filter (
      name:
      entries.${name} == "directory"
      && !(lib.hasPrefix "_" name)
      && builtins.pathExists (./. + "/${name}/default.nix")
    ) (builtins.attrNames entries)
  );
}
