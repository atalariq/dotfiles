{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.programs.lookapp.enable {
    programs.lookapp = {
      theme = "custom";
      settings = {
        launcher_hotkey = "none"; # The compositor owns the shortcut on Mango.
        ai_enabled = false;
        clipboard_history_limit = 50;
      };
    };
    systemd.user.services.look = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      Unit = {
        Description = "Look launcher and clipboard";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${lib.getExe config.programs.lookapp.package}";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
