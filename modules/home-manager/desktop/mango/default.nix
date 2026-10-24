{
  config,
  lib,
  pkgs,
  inputs,
  dotfilesLib,
  ...
}:
let
  cfg = config.dotfiles.desktop.mango;
  fragments = [
    "config.conf"
    "binds.conf"
    "rules.conf"
    "tags.conf"
    "gestures.conf"
    "scratchpad.conf"
  ];
  chooser = pkgs.writeShellScript "yazi-chooser" ''
    export PATH=${
      lib.makeBinPath [
        pkgs.kitty
        pkgs.yazi
        pkgs.coreutils
      ]
    }:"$PATH"
    ${builtins.readFile ./config/yazi-chooser}
  '';
  script = import ../../../../lib/runtime-script.nix { inherit pkgs lib; };
  scriptNames = [
    "shot"
    "shot-simple"
    "get_focus_info"
    "launcher-clipboard"
    "macro.sh"
  ];
  scripts = lib.genAttrs scriptNames (
    name:
    script {
      name = "mango-${name}";
      source = ./config/script + "/${name}";
      runtimeInputs = with pkgs; [
        bash
        findutils
        psmisc
        xdg-utils
        fyi
        inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
        kitty
        coreutils
        jq
        gnugrep
        gnused
        gawk
        procps
        wl-clipboard
        cliphist
        grim
        slurp
        libnotify
        imagemagick
        satty
        gpu-screen-recorder
        ripdrag
        (tesseract.override {
          enableLanguages = [
            "eng"
            "ind"
          ];
        })
        config.wayland.windowManager.mango.package
      ];
    }
  );
  validated = pkgs.runCommand "mango-config-check" { nativeBuildInputs = [ pkgs.gnugrep ]; } ''
    export HOME="$TMPDIR/home"
    mkdir -p "$HOME/.config/mango"
    cp ${./config}/*.conf "$HOME/.config/mango/"
    cp ${config.xdg.configFile."mango/theme.conf".source} "$HOME/.config/mango/theme.conf"
    cat > "$HOME/.config/mango/monitors.conf" <<'EOF'
    ${cfg.monitorConfig}
    EOF
    ${config.wayland.windowManager.mango.package}/bin/mango -p -c "$HOME/.config/mango/config.conf" > parser.log 2>&1
    cat parser.log
    # The pinned parser can return success after reporting invalid options.
    if grep -E 'ERROR|Unknown keyword|Invalid ' parser.log; then exit 1; fi
    touch "$out"
  '';
in
{
  imports = [ inputs.mangowm.hmModules.mango ];
  options.dotfiles.desktop.mango = {
    enable = lib.mkEnableOption "Mango tiling desktop";
    monitorConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Host-specific monitor rules; empty uses compositor detection.";
    };
  };
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion =
          config.dotfiles.terminal.kitty.enable
          && config.dotfiles.terminal.yazi.enable
          && config.dotfiles.desktop.helpers.enable
          && config.dotfiles.desktop.noctalia.enable;
        message = "The configured Mango workflow requires Kitty, Yazi, desktop helpers and Noctalia; enable them explicitly.";
      }
    ];
    wayland.windowManager.mango = {
      enable = true;
      systemd.enable = true;
      autostart_sh = "systemctl --user start noctalia.service dotfiles-clipboard-persist.service dotfiles-clipboard-history.service";
    };
    home.extraDependencies = [ validated ];
    xdg.configFile =
      (lib.genAttrs (map (name: "mango/${name}") fragments) (name: {
        source = lib.mkForce (dotfilesLib.source (./config + "/${builtins.baseNameOf name}"));
      }))
      // {
        "mango/monitors.conf".text = cfg.monitorConfig;
        "mango/theme.conf".text = lib.mkIf (!config.dotfiles.desktop.appearance.enable) "";
        "mango/script/shot".source =
          pkgs.writeShellScript "shot" ''exec ${scripts."shot"}/bin/mango-shot "$@"'';
        "mango/script/shot-simple".source =
          pkgs.writeShellScript "shot-simple" ''exec ${scripts."shot-simple"}/bin/mango-shot-simple "$@"'';
        "mango/script/get_focus_info".source =
          pkgs.writeShellScript "get_focus_info" ''exec ${scripts."get_focus_info"}/bin/mango-get_focus_info "$@"'';
        "mango/script/launcher-clipboard".source =
          pkgs.writeShellScript "launcher-clipboard" ''exec ${scripts."launcher-clipboard"}/bin/mango-launcher-clipboard "$@"'';
        "mango/script/macro.sh".source =
          pkgs.writeShellScript "macro.sh" ''exec ${scripts."macro.sh"}/bin/mango-macro.sh "$@"'';

        "xdg-desktop-portal-termfilechooser/config".text = ''
          [filechooser]
          cmd=${chooser}
          default_dir=${config.home.homeDirectory}
          open_mode=suggested
          save_mode=suggested
        '';
        "xdg-desktop-portal/mango-portals.conf".text = ''
          [preferred]
          default=gtk
          org.freedesktop.impl.portal.Secret=gnome-keyring
          org.freedesktop.impl.portal.ScreenCast=wlr
          org.freedesktop.impl.portal.Screenshot=wlr
          org.freedesktop.impl.portal.Inhibit=none
          org.freedesktop.impl.portal.FileChooser=termfilechooser
        '';
      };
  };
}
