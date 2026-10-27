{
  config,
  inputs,
  lib,
  pkgs,
  dotfilesLib,
  ...
}:
let
  cfg = config.programs.noctalia;
  format = pkgs.formats.toml { };
  root =
    entry:
    cfg.settings
    // {
      include = {
        autoload = false;
        files = [ entry ];
      };
    };
  generated = format.generate "noctalia-config.toml" (
    root "${config.xdg.configHome}/noctalia/native/config.toml"
  );
  validated = pkgs.runCommand "noctalia-native-config-check" { } ''
    export HOME="$TMPDIR/home"
    mkdir -p "$HOME" "$out/native"
    cp -R ${./config}/. "$out/native/"
    cp ${format.generate "noctalia-validation.toml" (root "native/config.toml")} "$out/config.toml"
    # The file form validates one TOML document; the directory form expands
    # native includes and validates the complete effective configuration.
    ${lib.getExe cfg.package} config validate "$out"
  '';
in
{
  imports = [ inputs.noctalia.homeModules.default ];
  options.dotfiles.desktop.noctalia.enable = lib.mkEnableOption "Noctalia desktop shell";
  config = lib.mkIf config.dotfiles.desktop.noctalia.enable {
    assertions = [
      {
        assertion = config.dotfiles.appearance.enable;
        message = "Noctalia requires the shared appearance module.";
      }
    ];
    programs.noctalia = {
      enable = true;
      systemd.enable = true;
      checkConfig = true;
      # Keep desktop ownership/font and Stylix theme values generated. Native
      # bar/lockscreen/usability files are included first; host overrides win.
      settings.shell = {
        polkit_agent = true;
        clipboard_enabled = false;
        font = config.stylix.fonts.sansSerif.name;
      };
    };
    home.extraDependencies = [ validated ];
    xdg.configFile = {
      # The complete include tree is validated above, using immutable inputs.
      "noctalia/config.toml".source = lib.mkForce generated;
      # Link the pure native tree as one directory; runtime state stays outside.
      "noctalia/native".source = dotfilesLib.sourceFor "noctalia" ./config;
    };
    # Preserve restarts when generated settings change, as well as the upstream
    # palette/root triggers. Native live edits use Noctalia's own file watcher.
    systemd.user.services.noctalia.Unit.X-Restart-Triggers = [ "${generated}" ];
  };
}
