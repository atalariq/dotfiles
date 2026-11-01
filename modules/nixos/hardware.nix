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
        TLP_PROFILE_AC = "BAL";
        TLP_PROFILE_BAT = "SAV";
        CPU_SCALING_GOVERNOR_ON_AC = "powersave";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_SCALING_GOVERNOR_ON_SAV = "powersave";
        # Since TLP 1.9, suffixes designate profiles: AC=performance,
        # BAT=balanced, SAV=power-saver, independent of the current power source.
        # Verified against tlp 1.10.2 func.d/10-tlp-func-cpu: profile
        # PRF/BAL/SAV selects the _ON_AC/_ON_BAT/_ON_SAV value, so a profile
        # chosen by hand or left over from an unplug applies _ON_AC on battery
        # too. That is what pinned this Ryzen 7 PRO 5850U to EPP=performance
        # plus platform_profile=performance while on battery (owner complaint:
        # "gampang panas"; observed last_pwr="0 1" on 2026-10-31).
        #
        # Thermal-first: every profile bucket now caps at balanced, so no
        # selection - manual, stale, or assigned - can run the machine hot.
        # Power-saver stays the coolest and boost policy is untouched.
        CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_performance";
        CPU_ENERGY_PERF_POLICY_ON_SAV = "power";
        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 1;
        CPU_BOOST_ON_SAV = 0;
        # X13 Gen 2a firmware advertises all three through platform_profile.
        PLATFORM_PROFILE_ON_AC = "balanced";
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
