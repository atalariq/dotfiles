{
  pkgs,
  ...
}:
{
  imports = [
    ../../../modules/nixos
    ./disko.nix
    ./hardware.nix
    ./media.nix
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
        "/home"
        "/var/lib/atticd"
        "/var/lib/jellyfin"
        "/var/lib/sops-nix"
        "/var/lib/tailscale"
        "/var/cache/jellyfin"
      ];
    };
    system.podman.enable = true;
    security.ssh-server.enable = true;
    security.secrets.enable = true;
    system.binary-cache.server = {
      enable = true;
      # Created once on the host (root-only, on /persist); never in Git.
      environmentFile = "/var/lib/atticd/atticd.env";
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
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJsjBE2+Q+1AYl7COPrxFpG4hqvI/7M6qGgCGDtUJmpc atalariq.dev@outlook.com"
    ];
  };

  # Remote access is the tailnet, not the shared kost LAN.
  services.tailscale.enable = true;
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  # No desktop, no greeter, no audio: SSH and services only.
}
