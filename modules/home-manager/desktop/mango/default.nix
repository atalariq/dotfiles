{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.dotfiles.desktop.mango;
  rendered = config.xdg.configFile."mango/config.conf".source;
in
{
  imports = [ inputs.mangowm.hmModules.mango ];
  options.dotfiles.desktop.mango = {
    enable = lib.mkEnableOption "Mango fallback session";
    monitorRules = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Host-owned monitor rules; empty leaves output detection to Mango.";
    };
  };
  config = lib.mkIf cfg.enable {
    wayland.windowManager.mango = {
      enable = true;
      package = import ./package.nix { inherit inputs pkgs; };
      systemd.enable = true;
      # The upstream HM module supplies its D-Bus/systemd environment bridge.
      autostart_sh = "systemctl --user start noctalia.service look.service";
      settings = lib.recursiveUpdate (import ./settings.nix) {
        monitor_rule = cfg.monitorRules;
        key_mode.default.bindn = lib.optional config.dotfiles.desktop.shelf.enable "CTRL+SUPER+ALT,S,spawn,pluto toggle";
      };
    };
    home.extraDependencies = [
      (pkgs.runCommand "mango-parser-check" { nativeBuildInputs = [ pkgs.gnugrep ]; } ''
        export HOME="$TMPDIR/home"
        mkdir -p "$HOME"
        ${config.wayland.windowManager.mango.package}/bin/mango -p -c ${rendered} > parser.log 2>&1
        cat parser.log
        if grep -E 'ERROR|Unknown keyword|Invalid ' parser.log; then exit 1; fi
        touch "$out"
      '')
    ];
    xdg.configFile."xdg-desktop-portal/mango-portals.conf".text = ''
      [preferred]
      default=gtk
      org.freedesktop.impl.portal.Secret=gnome-keyring
      org.freedesktop.impl.portal.ScreenCast=wlr
      org.freedesktop.impl.portal.Screenshot=wlr
      org.freedesktop.impl.portal.Inhibit=none
      org.freedesktop.impl.portal.FileChooser=gtk
    '';
  };
}
