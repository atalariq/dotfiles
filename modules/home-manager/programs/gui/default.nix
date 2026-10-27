{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.dotfiles.bundles.gui.enable = lib.mkEnableOption "the gui package bundle";

  # Graphical applications and desktop utilities that have no dedicated Home
  # Manager module: browsers, file manager, viewers, chat clients, media
  # creation/playback and the local concat editor. kitty and obs-studio keep
  # their own modules because they carry granular native config.
  config = lib.mkIf config.dotfiles.bundles.gui.enable {
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
      ncmpcpp
      libva-utils
      (pkgs.callPackage ./concat.nix { })
    ];
  };
}
