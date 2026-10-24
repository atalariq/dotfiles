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
    controller = with pkgs; [
      coreutils
      config.programs.lookapp.package
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
          cfg.desktop.noctalia.enable && config.programs.kitty.enable && config.programs.lookapp.enable;
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
  };
}
