{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.dotfiles.programs.plane.enable = lib.mkEnableOption "Plane Cloud desktop launcher";
  config = lib.mkIf config.dotfiles.programs.plane.enable {
    xdg.desktopEntries.plane = {
      name = "Plane";
      comment = "Project management on Plane Cloud";
      exec = "${pkgs.xdg-utils}/bin/xdg-open https://app.plane.so";
      icon = "applications-office";
      categories = [
        "Office"
        "ProjectManagement"
      ];
      terminal = false;
    };
  };
}
