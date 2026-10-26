{
  config,
  lib,
  pkgs,
  ...
}:
{

  options.dotfiles.programs.obs-studio.enable = lib.mkEnableOption "obs-studio configuration";

  config = lib.mkIf config.dotfiles.programs.obs-studio.enable {

    programs.obs-studio = {
      enable = true;
      plugins = [ pkgs.obs-studio-plugins.obs-move-transition ];
    };
    home.packages = [
      pkgs.audacity
      pkgs.ffmpeg
    ]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      pkgs.gpu-screen-recorder
      pkgs.gpu-screen-recorder-gtk
    ];
    # Runtime profiles are writable; seed manually from these optional templates.
    xdg.configFile."dotfiles/templates/obs" = {
      source = ./config;
      recursive = true;
    };
  };
}
