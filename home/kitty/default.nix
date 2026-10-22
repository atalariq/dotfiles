{
  config,
  lib,
  pkgs,
  checkout,
  ...
}:
{
  home.packages = [ pkgs.kitty ];
  xdg.configFile."kitty/kitty.conf".source =
    config.lib.file.mkOutOfStoreSymlink "${checkout}/home/kitty/config/kitty.conf";
  xdg.configFile."kitty/sessions".source =
    config.lib.file.mkOutOfStoreSymlink "${checkout}/home/kitty/config/sessions";
  # The directory stays writable for Noctalia's generated color fragment.
  home.activation.kittyThemeFragment = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p ${lib.escapeShellArg "${config.xdg.configHome}/kitty/themes"}
    if [ ! -e ${lib.escapeShellArg "${config.xdg.configHome}/kitty/themes/noctalia.conf"} ]; then
      run touch ${lib.escapeShellArg "${config.xdg.configHome}/kitty/themes/noctalia.conf"}
    fi
  '';
}
