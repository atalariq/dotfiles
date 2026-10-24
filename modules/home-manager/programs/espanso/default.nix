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
    xdg.configFile."espanso/match".source = dotfilesLib.source ./config/match;

  };
}
