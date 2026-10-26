{ lib, ... }:
let
  entries = builtins.readDir ./.;
in
{
  imports = [
    ./integrations.nix
  ]
  ++ map (name: ./. + "/${name}") (
    builtins.filter (
      name:
      entries.${name} == "directory"
      && !(lib.hasPrefix "_" name)
      && builtins.pathExists (./. + "/${name}/default.nix")
    ) (builtins.attrNames entries)
  );
}
