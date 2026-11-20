# Generic NixOS example. Change the hostname, timezone, and user if you want;
# nothing here is tied to a specific machine.
{
  pkgs,
  ...
}:
{
  imports = [ ../../modules/nixos ];

  networking.hostName = "caladan";
  time.timeZone = "Asia/Jakarta";
  i18n.defaultLocale = "en_US.UTF-8";
  system.stateVersion = "26.05";

  dotfiles.system.base.enable = true;

  # Placeholder layout for evaluation; replace it with your disk's UUIDs.
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/ESP";
    fsType = "vfat";
  };
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  users.users.atalariq = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
  };

  security.sudo.wheelNeedsPassword = true;
}
