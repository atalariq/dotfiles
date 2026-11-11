{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Audio ownership (services.pipewire, rtkit) stays with
  # dotfiles.desktop.audio; the block below only adds configuration when it
  # is on. Buffer sizes live next to the values that set them.
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
      # This used to force 64-sample buffers on every client. That is fine on
      # an idle machine and miserable on a busy one: a 1.3 ms quantum turns
      # any JVM pause or page-fault storm into an audible underrun, which is
      # how the crackle under Android Studio showed up. Keep the realtime
      # module, but size the graph for a desktop instead of a game console.
      services.pipewire.extraConfig = {
        pipewire."99-desktop-latency" = {
          "context.properties" = {
            "default.clock.quantum" = 1024;
            "default.clock.min-quantum" = 256;
            "default.clock.max-quantum" = 4096;
          };
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
        pipewire-pulse."99-desktop-latency"."pulse.properties" = {
          "server.address" = [ "unix:native" ];
          "pulse.min.req" = "1024/48000";
          "pulse.min.quantum" = "1024/48000";
          "pulse.min.frag" = "1024/48000";
        };
        client."99-desktop-latency"."stream.properties".node.latency = "2048/48000";
      };

      # The HDA codec powers down between streams and the resume click is
      # audible on the internal speakers. Keep the controller awake.
      boot.extraModprobeConfig = ''
        options snd_hda_intel power_save=0 power_save_controller=N
      '';

      # Headroom absorbs scheduler jitter before the graph reports an
      # underrun. WirePlumber applies this to every ALSA output node.
      services.pipewire.wireplumber.extraConfig."50-alsa-headroom" = {
        "monitor.alsa.rules" = [
          {
            matches = [
              { "node.name" = "~alsa_output.*"; }
            ];
            actions.update-props."api.alsa.headroom" = 2048;
          }
        ];
      };
    })
  ];
}
