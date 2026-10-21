{ config, pkgs, lib, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  programs.mango.enable = true;
  programs.niri.enable = true;

  hardware.graphics.enable = true;

  security.rtkit.enable = true;

  services.greetd = {
    enable = true;
    useTextGreeter = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions --cmd mango";
      user = "greeter";
    };
  };
  services.displayManager.defaultSession = "mango";

  hardware.bluetooth.enable = true;
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;
  # services.tlp.enable = true;
  services.udisks2.enable = true;
  services.gvfs.enable = true;

  services.pipewire = {
    enable = lib.mkDefault true;
    alsa.enable = lib.mkDefault true;
    pulse.enable = lib.mkDefault true;
  };

  programs.noctalia = {
    enable = true;
    recommendedServices.enable = true;
  };

  environment.systemPackages = with pkgs; [
    anki
    brave-origin
    brightnessctl
    google-chrome
    kitty
    nautilus
    obsidian
    slack
    wl-clipboard
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.symbols-only
    fira-code
    noto-fonts
    noto-fonts-color-emoji
    inter
  ];
}
