{ config, lib, pkgs, ... }:
{
  # Capabilities belonging to this AMD laptop, never to the portable home.
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.amd.updateMicrocode = true;
  services.fwupd.enable = true;
  services.fprintd.enable = true;
  services.libinput.enable = true;
  services.blueman.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.polkit.enable = true;

  # The camera already enumerates through uvcvideo; PipeWire is in desktop.nix.
  boot.kernelModules = [ "uvcvideo" ];
  hardware.graphics.enable32Bit = true;
  services.fstrim.enable = true;
  zramSwap = { enable = true; memoryPercent = 25; };
  # Keep power-profiles-daemon as the sole power policy service (desktop.nix).
  # Avoid forced CPU governors, TLP conflicts, and speculative suspend quirks.

  # systemd 258+ supplies Android USB uaccess rules; adb is in the dev shell.
  users.users.atalariq.extraGroups = [ "kvm" ];
  virtualisation.podman = {
    enable = true;
    dockerCompat = false;
    defaultNetwork.settings.dns_enabled = true;
  };
  programs.direnv = { enable = true; nix-direnv.enable = true; };
  environment.systemPackages = with pkgs; [
    android-studio
    usbutils pciutils v4l-utils
    libsecret
    satty ripdrag gpu-screen-recorder
    (tesseract.override { enableLanguages = [ "eng" "ind" ]; })
  ];
  system.extraDependencies = [ (pkgs.runCommand "validate-native-desktops" {} ''
    export HOME="$TMPDIR/home"
    export XDG_CACHE_HOME="$HOME/.cache"
    export XDG_RUNTIME_DIR="$TMPDIR/runtime"
    mkdir -p "$HOME" "$XDG_RUNTIME_DIR"
    mkdir -p "$HOME/.config"
    cp -R ${../../config/desktop/mango/.config/mango} "$HOME/.config/mango"
    ${config.programs.mango.package}/bin/mango -p -c "$HOME/.config/mango/config.conf"
    touch "$out"
  '') ];
}
