{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkMerge [
    (lib.mkIf config.dotfiles.development.podman.enable {
      virtualisation.podman = {
        enable = true;
        dockerCompat = false;
        defaultNetwork.settings.dns_enabled = true;
      };
      virtualisation.containers.enable = true;
      environment.systemPackages = [ pkgs.podman-compose ];
    })
  ];
}
