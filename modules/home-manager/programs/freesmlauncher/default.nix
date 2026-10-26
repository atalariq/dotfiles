{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.dotfiles.programs.freesmlauncher.enable =
    lib.mkEnableOption "Freesm Minecraft Java launcher";
  config = lib.mkIf config.dotfiles.programs.freesmlauncher.enable {
    home.packages = [ (pkgs.callPackage ./package.nix { }) ];
  };
}
