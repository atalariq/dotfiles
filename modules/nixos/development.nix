{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.dotfiles.development.emulation.enable =
    lib.mkEnableOption "QEMU binfmt emulation for foreign-architecture builds";

  config = lib.mkMerge [
    (lib.mkIf config.dotfiles.development.podman.enable {
      virtualisation.podman = {
        enable = true;
        # Docker-compatible CLI and socket for dev-workflow tooling.
        dockerCompat = true;
        dockerSocket.enable = true;
        defaultNetwork.settings.dns_enabled = true;
      };
      virtualisation.containers.enable = true;
      environment.systemPackages = [
        pkgs.podman-compose
        # The pinned podman module has no dockerCompose option, so the compose
        # v2 plugin comes from nixpkgs directly.
        pkgs.docker-compose
      ];
    })
    (lib.mkIf config.dotfiles.development.emulation.enable {
      boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
    })
  ];
}
