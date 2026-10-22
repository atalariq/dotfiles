{
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    inputs.mangowm.nixosModules.mango
    inputs.noctalia.nixosModules.default
  ];

  programs.mango.enable = true;
  programs.noctalia = {
    enable = true;
    recommendedServices.enable = true;
  };
  security.rtkit.enable = true;
  security.polkit.enable = true;
  services.greetd = {
    enable = true;
    useTextGreeter = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd mango";
      user = "greeter";
    };
  };
  # Rebuilds must not terminate the running graphical session.
  systemd.services.greetd.restartIfChanged = false;
  services.displayManager.defaultSession = "mango";
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-termfilechooser ];

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  services.libinput.enable = true;
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;
  services.udisks2.enable = true;
  services.gvfs.enable = true;
  services.pipewire = {
    enable = lib.mkDefault true;
    alsa.enable = lib.mkDefault true;
    pulse.enable = lib.mkDefault true;
  };

  services.espanso = {
    enable = true;
    package = pkgs.espanso-wayland;
    extraPackages = with pkgs; [
      bash
      curl
    ];
  };
  fonts.packages = with pkgs; [
    fira-code
    inter
    noto-fonts
    noto-fonts-color-emoji
    nerd-fonts.symbols-only
  ];
}
