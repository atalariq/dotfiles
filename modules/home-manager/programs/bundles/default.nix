{ lib, ... }:
let
  bundles = [
    "core"
    "cli"
    "gui"
    "dev"
    "gaming"
    "media"
    "comms"
  ];
in
{
  # Package bundles group baseline applications by purpose. Hosts enable the
  # bundles they want; a package belongs in a bundle only while it has no
  # dedicated module or Home Manager program option.
  imports = map (name: ./. + "/${name}.nix") bundles;

  options.dotfiles.bundles = lib.genAttrs bundles (name: {
    enable = lib.mkEnableOption "the ${name} package bundle";
  });
}
