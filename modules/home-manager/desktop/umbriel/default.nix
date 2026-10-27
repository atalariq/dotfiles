{
  config,
  lib,
  pkgs,
  dotfilesLib,
  ...
}:
let
  cfg = config.dotfiles.desktop.umbriel;
  format = pkgs.formats.toml { };
  # Umbriel expands includes first and applies this generated host/theme body
  # last. Only native behavior is live; feature/output/theme changes rebuild.
  root = entry: cfg.settings // { include.files = [ entry ]; };
  generated = format.generate "umbriel-config.toml" (
    root "${config.xdg.configHome}/umbriel/native/config.toml"
  );
  validated = pkgs.runCommand "umbriel-config-check" { } ''
    export HOME="$TMPDIR/home"
    mkdir -p "$HOME" "$out/native"
    cp -R ${./config}/. "$out/native/"
    cp ${format.generate "umbriel-validation.toml" (root "native/config.toml")} "$out/config.toml"
    ${pkgs.umbriel}/bin/umbriel config validate -c "$out/config.toml"
  '';
in
{
  options.dotfiles.desktop.umbriel = {
    enable = lib.mkEnableOption "Umbriel scrolling desktop";
    settings = lib.mkOption {
      inherit (format) type;
      default = { };
      description = "Generated Umbriel host/feature/theme overrides, applied after native TOML includes.";
    };
  };
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = pkgs.stdenv.hostPlatform.isLinux && config.dotfiles.desktop.noctalia.enable;
        message = "Umbriel requires Linux and Noctalia.";
      }
    ];
    home.packages = [
      pkgs.umbriel
      pkgs.xwayland
    ];
    home.extraDependencies = [ validated ];
    xdg.configFile = {
      "umbriel/config.toml".source = generated;
      # Link the pure native tree as one directory; runtime state stays outside.
      "umbriel/native".source = dotfilesLib.sourceFor "umbriel" ./config;
      "xdg-desktop-portal/umbriel-portals.conf".text = ''
        [preferred]
        default=umbriel;gtk
        org.freedesktop.impl.portal.Secret=gnome-keyring
        org.freedesktop.impl.portal.ScreenCast=umbriel
        org.freedesktop.impl.portal.Screenshot=umbriel
        org.freedesktop.impl.portal.FileChooser=gtk
      '';
    };
    # The pinned HM has no Umbriel module. Retain the packaged session launcher,
    # Noctalia/Look startup, selected Shelf binding, and host-owned outputs.
    dotfiles.desktop.umbriel.settings = {
      general.autostart = [ "systemctl --user start noctalia.service look.service" ];
      keybinds = lib.optionalAttrs config.dotfiles.desktop.shelf.enable {
        "Ctrl+Mod+Alt+S" = {
          action = "spawn:pluto toggle";
          repeat = false;
        };
      };
    };
  };
}
