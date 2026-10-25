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
  binds =
    builtins.readFile ./config/binds.conf
    + "\nkey_mode = default\n"
    + lib.concatMapStringsSep "\n" (
      shortcut:
      "bindn = CTRL+SUPER+ALT${lib.optionalString shortcut.shift "+SHIFT"},${shortcut.key},spawn,${shortcut.command}"
    ) (import ../shortcuts.nix);
  validated = pkgs.runCommand "mango-config-check" { nativeBuildInputs = [ pkgs.gnugrep ]; } ''
    export HOME="$TMPDIR/home"
    mkdir -p "$HOME/.config/mango"
    cp ${./config}/*.conf "$HOME/.config/mango/"
    cp --remove-destination ${pkgs.writeText "mango-binds.conf" binds} "$HOME/.config/mango/binds.conf"
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
          config.programs.kitty.enable
          && config.programs.yazi.enable
          && config.dotfiles.desktop.helpers.enable
          && config.dotfiles.desktop.noctalia.enable
          && config.dotfiles.programs.capture.enable;
        message = "The configured Mango workflow requires Kitty, Yazi, desktop helpers, Noctalia and capture; enable them explicitly.";
      }
    ];
    wayland.windowManager.mango = {
      enable = true;
      package = import ../../../../packages/mango.nix { inherit inputs pkgs; };
      systemd.enable = true;
      autostart_sh = "systemctl --user start noctalia.service look.service";
    };
    home.extraDependencies = [ validated ];
    xdg.configFile =
      (lib.genAttrs (map (name: "mango/${name}") fragments) (name: {
        source = lib.mkForce (dotfilesLib.source (./config + "/${builtins.baseNameOf name}"));
      }))
      // {
        "mango/binds.conf" = {
          source = lib.mkForce (pkgs.writeText "mango-binds.conf" binds);
        };
        "mango/monitors.conf".text = cfg.monitorConfig;
        "mango/theme.conf".text = lib.mkIf (!config.dotfiles.appearance.enable) "";
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
