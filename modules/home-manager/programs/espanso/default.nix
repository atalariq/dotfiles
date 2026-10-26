{
  config,
  lib,
  dotfilesLib,
  ...
}:
{

  options.dotfiles.programs.espanso.enable = lib.mkEnableOption "espanso configuration";

  config = lib.mkIf config.dotfiles.programs.espanso.enable {

    # NixOS owns the sole Wayland daemon and its capability wrapper.
    # Link individual matches: an out-of-store directory is opaque to HM's
    # recursive expansion and would replace Espanso's writable match directory.
    xdg.configFile = {
      "espanso/config/default.yml".source = dotfilesLib.sourceFor "espanso" ./config/default.yml;
    }
    // lib.listToAttrs (
      map (path: {
        name = "espanso/match/${lib.removePrefix (toString ./config/match + "/") (toString path)}";
        value.source = dotfilesLib.sourceFor "espanso" path;
      }) (lib.filesystem.listFilesRecursive ./config/match)
    );

  };
}
