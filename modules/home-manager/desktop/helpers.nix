{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  script = import ../../../lib/runtime-script.nix { inherit pkgs lib; };
  cfg = config.dotfiles;
  commands = {
    autostart = [ pkgs.systemd ];
    clipboard = with pkgs; [
      coreutils
      gnugrep
      gnused
      fzf
      cliphist
      wl-clipboard
    ];
    clipboard-delete-fzf = with pkgs; [
      coreutils
      fzf
      cliphist
    ];
    controller = with pkgs; [
      coreutils
      brightnessctl
      kitty
      brave-origin
      nautilus
      inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
    import-gsettings = with pkgs; [
      coreutils
      gnugrep
      glib
      dconf
    ];
    noctalia-autostart = [ pkgs.kitty ];
  };
  scripts = lib.mapAttrs (
    name: runtimeInputs:
    script {
      inherit name runtimeInputs;
      source = ./scripts + "/${name}";
    }
  ) commands;
in
{
  options.dotfiles.desktop.helpers.enable =
    lib.mkEnableOption "desktop command and clipboard integration";
  config = lib.mkIf cfg.desktop.helpers.enable {
    assertions = [
      {
        assertion =
          cfg.desktop.noctalia.enable
          && cfg.terminal.kitty.enable
          && cfg.desktop.brave.enable
          && cfg.desktop.files.enable;
        message = "Desktop controller helpers require explicit Noctalia, Kitty, Brave and desktop files features.";
      }
    ];
    home.packages = builtins.attrValues scripts;
    home.file = lib.mapAttrs' (
      name: package:
      lib.nameValuePair ".local/script/${name}" {
        source = pkgs.writeShellScript "compat-${name}" ''exec ${package}/bin/${name} "$@"'';
      }
    ) scripts;
    systemd.user.services = {
      dotfiles-clipboard-persist = {
        Unit = {
          Description = "Persist the Wayland clipboard";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.wl-clip-persist}/bin/wl-clip-persist --clipboard regular --reconnect-tries 0";
          Restart = "on-failure";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
      dotfiles-clipboard-history = {
        Unit = {
          Description = "Record Wayland clipboard history";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist store";
          Restart = "on-failure";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
