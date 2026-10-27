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
  mango = config.wayland.windowManager.mango;
  mangoLib = import "${inputs.mangowm}/nix/lib.nix" lib;
  generatedSettings = mangoLib.toMango {
    topCommandsPrefixes = mango.topPrefixes;
    bottomCommandsPrefixes = mango.bottomPrefixes;
  } mango.settings;
  # Keep the upstream D-Bus/systemd bridge and autostart script. The generated
  # wrapper applies only host/theme/integration values after the native sources.
  rootText = entry: ''
    # Native behavior is editable separately; host/theme selections still rebuild.
    source = ${entry}
    ${generatedSettings}
    ${mango.extraConfig}
    exec_once = ~/.config/mango/autostart.sh
  '';
  generated = pkgs.writeText "mango-config.conf" (
    rootText "${config.xdg.configHome}/mango/native/config.conf"
  );
  # Materialize the same include layout for the parser, using immutable source
  # files rather than following an out-of-store link into the owner's checkout.
  validated = pkgs.runCommand "mango-parser-check" { nativeBuildInputs = [ pkgs.gnugrep ]; } ''
    export HOME="$TMPDIR/home"
    mkdir -p "$HOME" "$out/native"
    cp -R ${./config}/. "$out/native/"
    cp ${pkgs.writeText "mango-validation.conf" (rootText "./native/config.conf")} "$out/config.conf"
    ${mango.package}/bin/mango -p -c "$out/config.conf" > parser.log 2>&1
    cat parser.log
    if grep -E 'ERROR|Unknown keyword|Invalid ' parser.log; then exit 1; fi
  '';
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
      autostart_sh = "systemctl --user start noctalia.service";
      settings = {
        monitor_rule = cfg.monitorRules;
        # The native binds file ends in resize mode. Select default explicitly
        # before appending this host-selected binding.
        key_mode.default.bindn = lib.optional config.dotfiles.desktop.shelf.enable "CTRL+SUPER+ALT,S,spawn,pluto toggle";
      };
    };
    home.extraDependencies = [ validated ];
    xdg.configFile = {
      # Override only upstream's generated config file, retaining its lifecycle.
      "mango/config.conf".source = lib.mkForce generated;
      # A pure native tree is linked as a directory; new fragments do not need
      # another Home Manager declaration. Generated lifecycle files stay outside.
      "mango/native".source = dotfilesLib.sourceFor "mango" ./config;
      "xdg-desktop-portal/mango-portals.conf".text = ''
        [preferred]
        default=gtk
        org.freedesktop.impl.portal.Secret=gnome-keyring
        org.freedesktop.impl.portal.ScreenCast=wlr
        org.freedesktop.impl.portal.Screenshot=wlr
        org.freedesktop.impl.portal.Inhibit=none
        org.freedesktop.impl.portal.FileChooser=gtk
      '';
    };
  };
}
