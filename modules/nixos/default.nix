# Generic NixOS baseline for the public dotfiles. Server services, secrets,
# disks, and hostnames stay in the private inventory repository.
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.dotfiles.system.base.enable = lib.mkEnableOption "the shared NixOS baseline";

  config = lib.mkIf config.dotfiles.system.base.enable {
    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "root"
        "@wheel"
      ];
    };

    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };

    programs.fish.enable = true;
    programs.bash.enable = true;
    programs.nix-ld.enable = true;
    environment.systemPackages = [ pkgs.bubblewrap ];

    services.openssh = {
      enable = lib.mkDefault true;
      settings = {
        PasswordAuthentication = lib.mkDefault false;
        KbdInteractiveAuthentication = lib.mkDefault false;
      };
    };

    networking.firewall.enable = lib.mkDefault true;
  };
}
