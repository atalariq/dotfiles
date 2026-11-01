{
  config,
  lib,
  pkgs,
  ...
}:
{

  options.dotfiles.programs.gui.obs-studio.enable = lib.mkEnableOption "obs-studio configuration";

  config = lib.mkIf config.dotfiles.programs.gui.obs-studio.enable {

    programs.obs-studio = {
      enable = true;
      plugins = [ pkgs.obs-studio-plugins.obs-move-transition ];
    };
    home.packages = lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      pkgs.obs-cmd
    ];
    # Runtime profiles are writable; seed manually from these optional templates.
    xdg.configFile."dotfiles/templates/obs" = {
      source = ./config/obs-studio;
      recursive = true;
    };
    # Local obs-websocket endpoint used by obs-cmd. obs-websocket binds
    # 127.0.0.1; first_load=false stops it from generating a password.
    # Schema verified against obs-websocket 5.7.4 Config.cpp (PARAM_* keys).
    xdg.configFile."obs-studio/plugin_config/obs-websocket/config.json".text = ''
      {"alerts_enabled":false,"auth_required":false,"first_load":false,"server_enabled":true,"server_password":"","server_port":4455}
    '';
  };
}
