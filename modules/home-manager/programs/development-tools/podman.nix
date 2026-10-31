{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.dotfiles.programs.development.podman.enable =
    lib.mkEnableOption "the podman package bundle";

  config = lib.mkIf config.dotfiles.programs.development.podman.enable {
    home.packages = with pkgs; [
      podman
      podman-compose
      devcontainer
      dive
      hadolint
      lazydocker
      yq
    ];
  };
}
