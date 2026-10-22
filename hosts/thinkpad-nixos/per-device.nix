{ pkgs, ... }:
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
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
