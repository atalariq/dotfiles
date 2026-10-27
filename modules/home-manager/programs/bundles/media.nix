{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Media creation, editing and playback clients. mpv and the mpd stack keep
  # their own Home Manager modules, so they are deliberately absent here.
  config = lib.mkIf config.dotfiles.bundles.media.enable {
    home.packages = with pkgs; [
      gimp
      inkscape
      blender
      kdePackages.kdenlive
      nicotine-plus
      anki
      ncmpcpp
    ];
  };
}
