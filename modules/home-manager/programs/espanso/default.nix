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
    # match/ can also contain owner matches and installed Espanso packages.
    # Preserve that mixed-ownership directory instead of replacing it with a
    # directory symlink; own only the declared native matches.
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
