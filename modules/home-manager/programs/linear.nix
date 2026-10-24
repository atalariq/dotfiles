{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.dotfiles.programs.linear.enable = lib.mkEnableOption "Linear web launcher";
  config = lib.mkIf config.dotfiles.programs.linear.enable {
    xdg.desktopEntries.linear = {
      name = "Linear";
      exec = "${pkgs.xdg-utils}/bin/xdg-open https://linear.app";
      icon = "applications-office";
      categories = [
        "Office"
        "ProjectManagement"
      ];
      terminal = false;
    };
  };
}
