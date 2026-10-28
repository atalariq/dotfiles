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
    ../nix-cache.nix
    inputs.mangowm.nixosModules.mango
    inputs.noctalia.nixosModules.default
    inputs.sops-nix.nixosModules.sops
    ./desktop.nix
    ./security.nix
    ./development.nix
    ./hardware.nix
    ./gaming
  ];
  options.dotfiles = {
    system.base.enable = lib.mkEnableOption "the shared NixOS baseline";
    system.appimage.enable = lib.mkEnableOption "AppImage binfmt support";
    desktop.audio.enable = lib.mkEnableOption "PipeWire audio";
    desktop.bluetooth.enable = lib.mkEnableOption "Bluetooth integration";
    desktop.printing.enable = lib.mkEnableOption "Printing support";
    desktop.files.enable = lib.mkEnableOption "desktop removable-media services";
    desktop.fonts.enable = lib.mkEnableOption "desktop fonts";
    desktop.espanso.enable = lib.mkEnableOption "Espanso Wayland service";
    desktop.umbriel.enable = lib.mkEnableOption "the Umbriel session";
    desktop.greeter.enable = lib.mkEnableOption "the Noctalia login greeter";
    desktop.mango.enable = lib.mkEnableOption "the Mango session";
    desktop.noctalia.enable = lib.mkEnableOption "Noctalia desktop services";
    security.authentication.enable = lib.mkEnableOption "desktop authentication";
    security.ssh-server.enable = lib.mkEnableOption "the OpenSSH server";
    security.secrets.enable = lib.mkEnableOption "sops-nix runtime secrets";
    security.tpm.enable = lib.mkEnableOption "TPM (Trusted Platform Module) support";
    development.podman.enable = lib.mkEnableOption "rootless Podman";
    hardware.thinkpad.enable = lib.mkEnableOption "balanced X13 AMD defaults";
    gaming.enable = lib.mkEnableOption "Gaming optimization and support for NixOS";
  };
  config = lib.mkMerge [
    (lib.mkIf config.dotfiles.system.base.enable {
      nix.settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        # Let the desktop user and the wheel group pass substituters and other
        # restricted settings through, so the flake fallback and `nh` work.
        trusted-users = [
          "root"
          "@wheel"
        ];
      };
      nixpkgs.config.allowUnfree = true;
      programs.fish.enable = true;
      # Translate system shell fragments at build time instead of spawning Bash
      # through foreign-env on every Fish startup.
      programs.fish.useBabelfish = lib.mkDefault true;
      programs.bash.enable = true;
      programs.nix-ld.enable = true;
      environment.systemPackages = [ pkgs.bubblewrap ];
    })
    (lib.mkIf config.dotfiles.system.appimage.enable {
      # nixpkgs adds appimage-run to systemPackages but keeps binfmt separate.
      programs.appimage = {
        enable = true;
        binfmt = true;
      };
    })
  ];
}
