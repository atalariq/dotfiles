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
    xdg.configFile."espanso/config/default.yml".source = dotfilesLib.source ./config/default.yml;
    # Espanso creates match/packages at runtime. Keep the directory writable
    # and let Home Manager own only the declared match files.
    xdg.configFile."espanso/match" = {
      source = dotfilesLib.source ./config/match;
      recursive = true;
    };

  };
}
