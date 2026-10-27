{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.dotfiles.bundles.jetbrains-ides.enable =
    lib.mkEnableOption "the jetbrains-ides package bundle";

  config = lib.mkIf config.dotfiles.bundles.jetbrains-ides.enable {
    home.packages = with pkgs; [
      android-studio
      jetbrains.rust-rover
      jetbrains.phpstorm
      jetbrains.goland
    ];
  };
}
