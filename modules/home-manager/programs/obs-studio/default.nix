{
  config,
  lib,
  pkgs,
  ...
}:
{

  options.dotfiles.programs.obs-studio.enable = lib.mkEnableOption "obs-studio configuration";

  config = lib.mkIf config.dotfiles.programs.obs-studio.enable {

    home.packages = [ pkgs.obs-studio ];
    # Runtime profiles are writable; seed manually from these optional templates.
    xdg.configFile."dotfiles/templates/obs/basic.ini".source = ./config/basic.ini;
    xdg.configFile."dotfiles/templates/obs/global.ini".source = ./config/global.ini;
  };
}
