{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.desktop.shelf;
  package = pkgs.callPackage ../../../packages/pluto-shelf.nix { };
  stop = (import ../../../lib/runtime-script.nix { inherit pkgs lib; }) {
    name = "pluto-shelf-stop";
    source = ./scripts/shelf-stop;
    runtimeInputs = [
      package
      pkgs.coreutils
      pkgs.gawk
    ];
  };
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
    home.packages = [
      package
      stop
      (pkgs.writeShellScriptBin "shelf-toggle" ''
        ${pkgs.systemd}/bin/systemctl --user start pluto-shelf.service || exit $?
        exec ${package}/bin/pluto toggle
      '')
    ];
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
        ExecStop = "${stop}/bin/pluto-shelf-stop $MAINPID";
        TimeoutStopSec = 15;
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
