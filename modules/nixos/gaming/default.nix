{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Low-latency graph settings, formerly supplied by nix-gaming's
  # pipewireLowLatency module. Audio ownership (services.pipewire, rtkit) stays
  # with dotfiles.desktop.audio; this only adds configuration when it is on.
  quantumRate = "64/48000";
in
{
  config = lib.mkMerge [
    (lib.mkIf config.dotfiles.gaming.enable {
      hardware.graphics.enable = lib.mkDefault true;
      hardware.graphics.enable32Bit = true;
      hardware.steam-hardware.enable = true;

      programs.steam = {
        package = pkgs.steam.override {
          extraArgs = "-wayland";
        };
        enable = true;
        protontricks.enable = true;
      };

      programs.gamemode = {
        enable = true;
        enableRenice = true;
        settings = {
          general = {
            # TLP owns EPP/platform policy. Keep amd-pstate-epp's powersave
            # governor, including under iGPU load; boost via tlpctl launch.
            desiredgov = "powersave";
            igpu_desiredgov = "powersave";
            renice = 5;
            ioprio = 4;
            inhibit_screensaver = 1;
            disable_splitlock = 0;
          };
          cpu = {
            park_cores = "no";
            pin_cores = "no";
          };
        };
      };

      programs.gamescope = {
        enable = true;
        capSysNice = true;
      };

      # SteamOS sysctls, formerly nix-gaming's platformOptimizations module.
      # Last checked against steamos-customizations-jupiter-20250117.1.
      boot.kernel.sysctl = {
        # 20-shed.conf
        "kernel.sched_cfs_bandwidth_slice_us" = 3000;
        # 20-net-timeout.conf: games cannot always reuse TCP ports after a
        # quick restart, and the default timeout is too long.
        "net.ipv4.tcp_fin_timeout" = 5;
        # 30-splitlock.conf: avoid intentional slowdowns from split locks
        # (kernel v6.0+).
        "kernel.split_lock_mitigate" = 0;
        # 30-vm.conf: MAX_INT minus MAPCOUNT_ELF_CORE_MARGIN.
        "vm.max_map_count" = 2147483642;
      };

      environment.systemPackages = with pkgs; [
        steam-run
        steamtinkerlaunch
        dxvk
        mangohud
        bottles
        heroic
        osu-lazer-bin
        gzdoom

        # Console Games Emulator
        mednafen # Multi-system (CLI-only)
        mgba # Game Boy
        snes9x # Super Nintendo (SNES).
        pcsx2 # PlayStation 2

        # Minecraft Bedrock and Java launcher
        mcpelauncher-ui-qt
        (pkgs.callPackage ./freesmlauncher.nix { })
      ];
    })
    (lib.mkIf (config.dotfiles.gaming.enable && config.dotfiles.desktop.audio.enable) {
      services.pipewire.extraConfig = {
        pipewire."99-lowlatency" = {
          "context.properties"."default.clock.min-quantum" = 64;
          "context.modules" = [
            {
              name = "libpipewire-module-rt";
              flags = [
                "ifexists"
                "nofail"
              ];
              args = {
                "nice.level" = -15;
                "rt.prio" = 88;
                "rt.time.soft" = 200000;
                "rt.time.hard" = 200000;
              };
            }
          ];
        };
        pipewire-pulse."99-lowlatency"."pulse.properties" = {
          "server.address" = [ "unix:native" ];
          "pulse.min.req" = quantumRate;
          "pulse.min.quantum" = quantumRate;
          "pulse.min.frag" = quantumRate;
        };
        client."99-lowlatency"."stream.properties" = {
          "node.latency" = quantumRate;
          "resample.quality" = 1;
        };
      };
    })
  ];
}
