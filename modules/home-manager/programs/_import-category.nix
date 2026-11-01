# Import every package module in a category directory.
#
# Convention:
#   <category>/default.nix       the category core (or a stub for host-local groups)
#   <category>/<pname>.nix       one opt-in package module
#   <category>/_*.nix            helper modules, imported explicitly by default.nix
#   <category>/config/<pname>/   native configuration for <pname>
#
# Directories with their own default.nix are supported too, so a package that
# outgrows a single file can become <category>/<pname>/ without changing this
# helper. The top-level programs/default.nix only sees categories.
{
  lib,
  dir,
}:
let
  entries = builtins.readDir dir;
  isModule =
    name: type:
    !(lib.hasPrefix "_" name)
    && name != "default.nix"
    && name != "config"
    && (
      (type == "regular" && lib.hasSuffix ".nix" name)
      || (type == "directory" && builtins.pathExists (dir + "/${name}/default.nix"))
    );
  names = builtins.filter (name: isModule name entries.${name}) (builtins.attrNames entries);
in
map (name: dir + "/${name}") names
