{ pkgs, ... }:
{
  imports = [
    ../../../modules/nixos
    ./hardware-configuration.nix
    ./per-device.nix
  ];
  networking.hostName = "thinkpad-x13";
  networking.networkmanager.enable = true;
  time.timeZone = "Asia/Jakarta";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = builtins.listToAttrs (
    map
      (name: {
        inherit name;
        value = "en_GB.UTF-8";
      })
      [
        "LC_ADDRESS"
        "LC_IDENTIFICATION"
        "LC_MEASUREMENT"
        "LC_MONETARY"
        "LC_NAME"
        "LC_NUMERIC"
        "LC_PAPER"
        "LC_TELEPHONE"
        "LC_TIME"
      ]
  );
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
  # Device input policy belongs to this host; headless hosts stay inert.
  services.keyd = {
    enable = true;
    keyboards.superkey = {
      ids = [ "*" ];
      settings = {
        main.capslock = "overload(superkey, esc)";
        "superkey:C-M-A" = { };
      };
    };
  };
  users.users.atalariq = {
    isNormalUser = true;
    description = "Atalariq Barra Hadinugraha";
    shell = pkgs.bash;
    extraGroups = [
      "networkmanager"
      "wheel"
      "kvm"
      "gamemode"
    ];
    linger = true;
  };
  dotfiles = {
    system.base.enable = true;
    desktop.audio.enable = true;
    desktop.bluetooth.enable = true;
    desktop.files.enable = true;
    desktop.fonts.enable = true;
    desktop.espanso.enable = true;
    desktop.mango.enable = true;
    desktop.umbriel.enable = true;
    desktop.greeter.enable = true;
    desktop.noctalia.enable = true;
    security.authentication.enable = true;
    security.ssh.enable = false;
    security.secrets.enable = true;
    development.podman.enable = true;
    development.lerd.enable = true;
    hardware.thinkpad.enable = true;
    gaming.steam.enable = true;
  };
  services.displayManager.defaultSession = "umbriel";
  services.displayManager.noctalia-greeter.settings.session.default = "Umbriel";
  system.stateVersion = "26.05";
}
