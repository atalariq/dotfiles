{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.dotfiles.hardware.thinkpad.enable {
    # Matches nixos-hardware's common AMD graphics recommendation without an
    # extra input for settings already owned by this host.
    hardware.amdgpu.initrd.enable = lib.mkDefault true;
    # TLP owns device policy; tlp-pd exposes that policy through the standard
    # desktop D-Bus interface. Never run power-profiles-daemon alongside it.
    services.power-profiles-daemon.enable = false;
    services.upower.enable = true;
    services.tlp = {
      enable = true;
      pd.enable = true;
      settings = {
        TLP_AUTO_SWITCH = 2;
        # TLP 1.9+ suffixes designate profiles, not the current power source:
        # _ON_AC is the performance profile, _ON_BAT balanced, _ON_SAV
        # power-saver. Assign PRF on AC and BAL on battery so the machine runs
        # at full performance while charging and balanced on battery.
        TLP_PROFILE_AC = "PRF";
        TLP_PROFILE_BAT = "BAL";
        CPU_SCALING_GOVERNOR_ON_AC = "powersave";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_SCALING_GOVERNOR_ON_SAV = "powersave";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
        CPU_ENERGY_PERF_POLICY_ON_SAV = "power";
        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 1;
        CPU_BOOST_ON_SAV = 0;
        # X13 Gen 2a firmware advertises all three through platform_profile.
        PLATFORM_PROFILE_ON_AC = "performance";
        PLATFORM_PROFILE_ON_BAT = "balanced";
        PLATFORM_PROFILE_ON_SAV = "low-power";
        USB_EXCLUDE_AUDIO = 1;
        USB_EXCLUDE_PHONE = 1;
        # Existing charge thresholds and vendor thermal limits are retained.
      };
    };
    nix.settings = {
      max-jobs = 2;
      cores = 2;
      sandbox = true;
    };
    environment.systemPackages = [
      pkgs.android-tools
    ];
    networking.firewall = {
      enable = true;
      # Syncthing transport/discovery and LocalSend. Management UIs stay local.
      allowedTCPPorts = [
        22000
        53317
      ];
      allowedUDPPorts = [
        22000
        21027
        53317
      ];
    };
  };
}
