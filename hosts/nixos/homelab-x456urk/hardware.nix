# Platform profile for the ASUS X456URK (i5-7200U, Intel HD 620, NVIDIA 930MX
# unused). Disk layout lives in disko.nix; this file only carries firmware,
# kernel, power and boot-manager choices.
{
  pkgs,
  ...
}:
{
  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  # The discrete GPU is not used: no CUDA/NVENC, and nouveau only adds risk.
  boot.blacklistedKernelModules = [
    "nouveau"
    "nvidia"
    "nvidia_drm"
    "nvidia_modeset"
  ];

  # VA-API for Jellyfin transcoding on the integrated GPU.
  hardware.graphics = {
    enable = true;
    extraPackages = [ pkgs.intel-media-driver ];
  };

  boot = {
    kernelPackages = pkgs.linuxPackages;
    kernelModules = [ ];
    initrd.availableKernelModules = [
      "ahci"
      "sd_mod"
      "uas"
      "usb_storage"
      "xhci_pci"
    ];
    loader = {
      systemd-boot = {
        enable = true;
        # Room for a rollback generation, but not an unbounded ESP.
        configurationLimit = 4;
      };
      efi.canTouchEfiVariables = true;
    };
  };

  # A laptop with a dead battery must behave like a server: closing the lid
  # must not suspend it, and it must come back after a power cut.
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
  };

  # 24/7 media disk: keep it spinning instead of parking the heads every few
  # seconds (Load_Cycle_Count was already 543k when it arrived).
  services.udev.extraRules = ''
    ACTION=="add|change", SUBSYSTEM=="block", ENV{ID_SERIAL}=="HGST_HTS541010A9E680_JD1008DM2BNHTV", RUN+="${pkgs.hdparm}/bin/hdparm -q -B 254 -S 0 /dev/%k"
  '';

  services.smartd.enable = true;
  services.fstrim.enable = true;
  zramSwap.enable = true;

  # Wired wake-on-LAN needs the built-in NIC; USB adapters cannot do it.
  networking.interfaces.enp2s0.wakeOnLan.enable = true;
}
