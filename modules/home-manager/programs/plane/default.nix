{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.dotfiles.programs.plane.enable = lib.mkEnableOption "official Plane desktop application";
  config = lib.mkIf config.dotfiles.programs.plane.enable {
    home.packages = [ (pkgs.callPackage ./package.nix { }) ];
  };
}
