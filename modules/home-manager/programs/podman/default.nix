{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.dotfiles.bundles.podman.enable = lib.mkEnableOption "the podman package bundle";

  config = lib.mkIf config.dotfiles.bundles.podman.enable {
    home.packages = with pkgs; [
      podman
      podman-compose
    ];
  };
}
