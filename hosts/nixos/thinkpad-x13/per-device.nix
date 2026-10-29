{ pkgs, lib, ... }:
{
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = true;
  # The ESP is 1 GiB; without a limit every generation keeps its kernel and
  # initrd there until the filesystem fills up. Lanzaboote's measured boot
  # caps this at 4 (systemd-pcrlock assertion), so keep them aligned.
  boot.loader.systemd-boot.configurationLimit = 4;
  # Secure Boot via lanzaboote (UKI signing). Keys are generated and enrolled
  # declaratively but triggered manually: activate once, then run
  # `systemctl start prepare-sb-auto-enroll` and reboot to enroll PK/KEK/db
  # (+ Microsoft) in firmware. autoReboot stays off so reboots are owner-timed.
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
    configurationLimit = 4;
    autoGenerateKeys.enable = true;
    autoEnrollKeys = {
      enable = true;
      includeMicrosoftKeys = true;
      autoReboot = false;
    };
    measuredBoot = {
      enable = true;
      # Docs default; PCRs 1-3 are flaky on real hardware.
      pcrs = [
        0
        4
        7
      ];
    };
  };
  # Scripted initrd is gone upstream; systemd initrd (with its pcrlock token
  # support) is now unconditional, so no enable flag is needed.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd.luks.devices."luks-2a5e6488-3f57-4a04-ba0f-0d6582bf5975".device =
    "/dev/disk/by-uuid/2a5e6488-3f57-4a04-ba0f-0d6582bf5975";
  boot.kernelModules = [ "uvcvideo" ];

  hardware.enableRedistributableFirmware = true;
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  services.fwupd.enable = true;
  services.fstrim.enable = true;
  zramSwap = {
    enable = true;
    memoryPercent = 25;
  };
  environment.systemPackages = with pkgs; [
    usbutils
    pciutils
    v4l-utils
  ];
}
