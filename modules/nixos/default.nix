{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
{
  # Importing a catalogue declares options; the host owns activation.
  imports = [
    inputs.mangowm.nixosModules.mango
    inputs.noctalia.nixosModules.default
    inputs.sops-nix.nixosModules.sops
    ./desktop.nix
    ./security.nix
    ./development.nix
    ./hardware.nix
  ];
  options.dotfiles = {
    system.base.enable = lib.mkEnableOption "the shared NixOS baseline";
    desktop.capture.enable = lib.mkEnableOption "GPU Screen Recorder system integration";
    desktop.audio.enable = lib.mkEnableOption "PipeWire audio";
    desktop.bluetooth.enable = lib.mkEnableOption "Bluetooth integration";
    desktop.files.enable = lib.mkEnableOption "desktop removable-media services";
    desktop.fonts.enable = lib.mkEnableOption "desktop fonts";
    desktop.espanso.enable = lib.mkEnableOption "Espanso Wayland service";
    desktop.umbriel.enable = lib.mkEnableOption "the Umbriel session";
    desktop.greeter.enable = lib.mkEnableOption "the Noctalia login greeter";
    desktop.mango.enable = lib.mkEnableOption "the Mango session";
    desktop.noctalia.enable = lib.mkEnableOption "Noctalia desktop services";
    security.authentication.enable = lib.mkEnableOption "desktop authentication";
    security.ssh.enable = lib.mkEnableOption "the OpenSSH server";
    security.secrets.enable = lib.mkEnableOption "sops-nix runtime secrets";
    development.podman.enable = lib.mkEnableOption "rootless Podman";
    development.lerd.enable = lib.mkEnableOption "Lerd .test development";
    hardware.thinkpad.enable = lib.mkEnableOption "balanced X13 AMD defaults";
    gaming.steam.enable = lib.mkEnableOption "Steam system integration";
  };
  config = lib.mkMerge [
    (lib.mkIf config.dotfiles.system.base.enable {
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];
      nixpkgs.config.allowUnfree = true;
      programs.fish.enable = true;
      programs.bash.enable = true;
      programs.nix-ld.enable = true;
      environment.systemPackages = [ pkgs.bubblewrap ];
    })
    (lib.mkIf config.dotfiles.security.ssh.enable { services.openssh.enable = true; })
    (lib.mkIf config.dotfiles.gaming.steam.enable {
      programs.steam.enable = true;
      hardware.graphics.enable32Bit = true;
    })
  ];
}
