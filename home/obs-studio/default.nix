{
  config,
  lib,
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.obs-studio ];
  # Only seed absent profiles. Scenes, credentials and existing profiles stay writable.
  home.activation.obsProfileSeed = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    profile_root=${lib.escapeShellArg "${config.xdg.configHome}/obs-studio/basic/profiles"}
    if [ ! -e "$profile_root" ] && [ ! -L "$profile_root" ]; then
      run mkdir -p "$profile_root/Personal"
      run cp ${./config/basic.ini} "$profile_root/Personal/basic.ini"
      run chmod u+w "$profile_root/Personal/basic.ini"
      global_config=${lib.escapeShellArg "${config.xdg.configHome}/obs-studio/global.ini"}
      if [ ! -e "$global_config" ] && [ ! -L "$global_config" ]; then
        run cp ${./config/global.ini} "$global_config"
        run chmod u+w "$global_config"
      fi
    fi
  '';
}
