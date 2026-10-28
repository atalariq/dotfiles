{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.dotfiles.programs.development.jetbrains.enable =
    lib.mkEnableOption "the Jetbrains IDEs package bundle";

  config = lib.mkIf config.dotfiles.programs.development.jetbrains.enable {
    home.packages = with pkgs; [
      jetbrains.goland
      jetbrains.phpstorm
      jetbrains.rust-rover
      jetbrains.webstorm
    ];
  };
}
