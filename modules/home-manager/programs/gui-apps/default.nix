{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.dotfiles.programs.gui.enable = lib.mkEnableOption "the gui package bundle";

  # Graphical applications and desktop utilities that have no dedicated Home
  # Manager module: browsers, file manager, viewers, chat clients and media
  # creation/playback. kitty and obs-studio keep their own modules because they
  # carry granular native config.
  config = lib.mkIf config.dotfiles.programs.gui.enable {
    home.packages = with pkgs; [
      brave-origin
      google-chrome
      nautilus
      file-roller
      obsidian
      readest
      localsend
      scrcpy
      wdisplays
      wl-mirror
      figma-linux
      discord
      slack
      gimp
      inkscape
      blender
      kdePackages.kdenlive
      nicotine-plus
      anki
      libva-utils
    ];
  };
}
