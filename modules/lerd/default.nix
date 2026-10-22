{ inputs, pkgs, ... }:
{
  environment.systemPackages = [
    inputs.lerd.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
  virtualisation.podman = {
    enable = true;
    dockerCompat = false;
    defaultNetwork.settings.dns_enabled = true;
  };
  virtualisation.containers.enable = true;
  boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 80;
  users.users.atalariq.linger = true;

  # A stopped Lerd resolver affects only .test; upstream DNS stays on network links.
  services.resolved.enable = true;
  services.resolved.dnsDelegates.lerd.Delegate = {
    DNS = "127.0.0.1:5300";
    Domains = [ "~test" ];
    DefaultRoute = false;
  };
  networking.networkmanager.dns = "systemd-resolved";

  systemd.user.tmpfiles.rules = [
    "L %h/.local/bin/lerd - - - - /run/current-system/sw/bin/lerd"
  ];
  # Add security.pki.certificateFiles only after generating the public mkcert CA.
}
