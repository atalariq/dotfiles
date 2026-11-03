{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ../../../modules/nixos
    ./disko.nix
    ./hardware.nix
    ./media.nix
    ./network.nix
    ./apps.nix
    ./bookorbit.nix
  ];

  networking.hostName = "homelab-x456urk";
  time.timeZone = "Asia/Jakarta";
  i18n.defaultLocale = "en_US.UTF-8";
  system.stateVersion = "26.05";

  dotfiles = {
    system.base.enable = true;
    # Root is wiped on every boot; the persistence list lives in
    # modules/nixos/impermanence.nix plus the host additions below.
    system.impermanence = {
      enable = true;
      directories = [
        "/etc/NetworkManager/system-connections"
        "/home"
        "/var/cache/jellyfin"
        "/var/lib/actual"
        "/var/lib/atticd"
        "/var/lib/bazarr"
        "/var/lib/bookorbit"
        "/var/lib/jellyfin"
        "/var/lib/memos"
        "/var/lib/navidrome"
        "/var/lib/prowlarr"
        "/var/lib/qBittorrent"
        "/var/lib/radarr"
        "/var/lib/sonarr"
        "/var/lib/sops-nix"
        "/var/lib/tailscale"
        "/var/lib/vikunja"
        "/var/lib/NetworkManager"
      ];
    };
    system.podman.enable = true;
    security.ssh-server.enable = true;
    security.secrets.enable = true;
    system.binary-cache.server = {
      enable = true;
      environmentFile = config.sops.secrets.attic_env.path;
    };
  };

  sops = {
    defaultSopsFile = ../../../secrets/homelab-x456urk/secrets.sops.yaml;
    secrets = {
      attic_env = { };
      bookorbit_env = { };
      headscale_authkey = { };
      restic_env = { };
      wifi_psk = { };
      wifi_ssid = { };
    };
  };

  # Password changes are not persisted by design; the hash file must exist in
  # /persist before the first boot or sudo/console login is impossible.
  users.mutableUsers = false;
  services.openssh = {
    openFirewall = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  users.users.atalariq = {
    isNormalUser = true;
    description = "Atalariq Barra Hadinugraha";
    shell = pkgs.bash;
    extraGroups = [
      "wheel"
      "podman"
      "media"
    ];
    linger = true;
    hashedPasswordFile = "/persist/secrets/atalariq.passwd";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJsjBE2+Q+1AYl7COPrxFpG4hqvI/7M6qGgCGDtUJmpc atalariq@thinkpad-x13"
    ];
  };

  # Remote access is the tailnet, not the shared kost LAN. Headscale owns the
  # control plane; the preauth key is seeded through sops.
  services.tailscale = {
    enable = true;
    authKeyFile = config.sops.secrets.headscale_authkey.path;
    extraUpFlags = [ "--login-server=https://headscale.atalariq.dev" ];
  };
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  # NetworkManager stores profiles under /etc, which is volatile. This oneshot
  # materializes the home Wi-Fi profile from sops before NM starts, so the PSK
  # never sits in the Nix store or the repository.
  systemd.services.homelab-wifi-profile = {
    description = "Materialize the home Wi-Fi profile from sops";
    wantedBy = [ "NetworkManager.service" ];
    before = [ "NetworkManager.service" ];
    after = [
      "persist.mount"
      "sops-install-secrets.service"
    ];
    requires = [ "persist.mount" ];
    serviceConfig.Type = "oneshot";
    script = ''
      umask 077
      install -d -m 0700 /persist/etc/NetworkManager/system-connections
      {
        printf '[connection]\nid=home\ntype=wifi\nautoconnect=true\nautoconnect-priority=10\n\n'
        printf '[wifi]\nssid=%s\n\n' "$(cat /run/secrets/wifi_ssid)"
        printf '[wifi-security]\nkey-mgmt=wpa-psk\npsk=%s\n\n' "$(cat /run/secrets/wifi_psk)"
        printf '[ipv4]\nmethod=auto\n\n[ipv6]\nmethod=auto\n'
      } > /persist/etc/NetworkManager/system-connections/home.nmconnection
      chmod 600 /persist/etc/NetworkManager/system-connections/home.nmconnection
    '';
  };

  systemd.services.atticd.after = [ "sops-install-secrets.service" ];
  systemd.services.tailscaled-autoconnect.after = [ "sops-install-secrets.service" ];

  # No desktop, no greeter, no audio: SSH and services only.
}
