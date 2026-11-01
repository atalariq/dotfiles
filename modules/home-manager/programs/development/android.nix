{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.dotfiles.programs.development.android.enable =
    lib.mkEnableOption "Android Development Tools bundle";

  config = lib.mkIf config.dotfiles.programs.development.android.enable {
    home.packages = with pkgs; [
      android-tools
      android-studio
    ];
  };
}
