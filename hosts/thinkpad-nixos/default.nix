{ ... }:
{
  imports = [
    ../standard.nix
    ./hardware-configuration.nix
    ./per-device.nix
  ];

  networking.hostName = "thinkpad-nixos";
  networking.networkmanager.enable = true;
  time.timeZone = "Asia/Jakarta";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
  users.users.atalariq = {
    isNormalUser = true;
    description = "Atalariq Barra Hadinugraha";
    extraGroups = [
      "networkmanager"
      "wheel"
      "kvm"
    ];
  };

  system.stateVersion = "26.05";
}
