{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.dotfiles.development = {
    android.enable = lib.mkEnableOption "android tools";
    containers.enable = lib.mkEnableOption "containers tools";
  };
  config = lib.mkMerge [
    (lib.mkIf config.dotfiles.development.android.enable {
      home.packages = with pkgs; [ android-studio ];
    })
    (lib.mkIf config.dotfiles.development.containers.enable {
      home.packages = with pkgs; [
        podman
        podman-compose
      ];
    })
  ];
}
