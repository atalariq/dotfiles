{
  config,
  lib,
  ...
}:
{
  options.dotfiles.programs.gui.obs-studio.enable =
    lib.mkEnableOption "OBS Studio config (the package is owned by the host)";

  config = lib.mkIf config.dotfiles.programs.gui.obs-studio.enable {
    # OBS owns its scenes, profiles and plugin state under ~/.config/obs-studio.
    # This module only writes the one file another tool depends on: the local
    # obs-websocket endpoint used by obs-cmd. OBS is never started at login.
    #
    # obs-websocket binds 127.0.0.1; first_load=false stops it from generating
    # a password. Schema verified against obs-websocket 5.7.4 Config.cpp
    # (PARAM_* keys).
    xdg.configFile."obs-studio/plugin_config/obs-websocket/config.json".text = ''
      {"alerts_enabled":false,"auth_required":false,"first_load":false,"server_enabled":true,"server_password":"","server_port":4455}
    '';
  };
}
