{
  config,
  lib,
  inputs,
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
    (lib.mkIf config.dotfiles.development.lerd.enable {
      assertions = [
        {
          assertion = config.dotfiles.development.podman.enable;
          message = "Lerd requires dotfiles.development.podman.enable.";
        }
      ];
      environment.systemPackages = [ inputs.lerd.packages.${pkgs.stdenv.hostPlatform.system}.default ];
      boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 80;
      services.resolved.enable = true;
      services.resolved.dnsDelegates.lerd.Delegate = {
        DNS = "127.0.0.1:5300";
        Domains = [ "~test" ];
        DefaultRoute = false;
      };
      networking.networkmanager.dns = "systemd-resolved";
      systemd.user.tmpfiles.rules = [ "L %h/.local/bin/lerd - - - - /run/current-system/sw/bin/lerd" ];
      # Lerd's PHP 8.5 Quadlet hardcodes /bin/mkdir, absent on NixOS.
      # Extend the generated unit; leave its container and runtime config intact.
      systemd.user.services.lerd-php85-fpm = {
        overrideStrategy = "asDropin";
        serviceConfig.ExecStartPre = [
          ""
          "${pkgs.coreutils}/bin/mkdir -p -m 0700 %t/lerd/env"
        ];
      };
    })
  ];
}
