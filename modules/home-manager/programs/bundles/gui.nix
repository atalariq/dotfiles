{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Graphical applications and desktop utilities: browsers, file manager,
  # document viewers, screen mirroring/control and design clients.
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
    ];
  };
}
