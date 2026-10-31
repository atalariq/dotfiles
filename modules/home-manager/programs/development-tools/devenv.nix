{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.dotfiles.programs.development.devenv.enable =
    lib.mkEnableOption "the devenv CLI for Nix-driven project environments";

  config = lib.mkIf config.dotfiles.programs.development.devenv.enable {
    home.packages = [ pkgs.devenv ];
  };
}
