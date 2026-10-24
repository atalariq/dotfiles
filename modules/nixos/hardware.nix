{
  config,
  lib,
  pkgs,
  ...
}:
let
  boost = pkgs.writeShellApplication {
    name = "dotfiles-boost";
    runtimeInputs = [ pkgs.tlp-pd ];
    text = ''
      if [ "$#" -eq 0 ]; then
        echo 'Usage: dotfiles-boost command [arguments...]' >&2
        exit 2
      fi
      exec tlpctl launch --profile performance -- "$@"
    '';
  };
in
{
  config = lib.mkIf config.dotfiles.hardware.thinkpad.enable {
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
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_performance";
        CPU_ENERGY_PERF_POLICY_ON_SAV = "power";
        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 1;
        CPU_BOOST_ON_SAV = 0;
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
      boost
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
