{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.desktop.shelf;
  package = pkgs.callPackage ./package.nix { };
  format = pkgs.formats.toml { };
in
{
  options.dotfiles.desktop.shelf = {
    enable = lib.mkEnableOption "Pluto drop shelf";
    settings = lib.mkOption {
      type = format.type;
      default = { };
      description = "Declarative Pluto configuration; user state remains in XDG_DATA_HOME/pluto.";
    };
  };
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = pkgs.stdenv.hostPlatform.isLinux;
        message = "Pluto shelf requires Linux Wayland.";
      }
    ];
    home.packages = [ package ];
    dotfiles.desktop.shelf.settings = {
      shake = false;
      edge = "right";
      strip_width = 3;
    };
    xdg.configFile."pluto/config.toml".source = format.generate "pluto-config.toml" cfg.settings;
    systemd.user.services.pluto-shelf = {
      Unit = {
        Description = "Pluto drop shelf";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "dbus";
        BusName = "io.pluto.Pluto";
        ExecStart = "${package}/bin/pluto";
        TimeoutStopSec = 15;
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
