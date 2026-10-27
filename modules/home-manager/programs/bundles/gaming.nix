{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Games, emulators and the Godot engine runtime used for game projects.
  config = lib.mkIf config.dotfiles.bundles.gaming.enable {
    home.packages = with pkgs; [
      osu-lazer
      gzdoom
      mcpelauncher-ui-qt
      mgba
      mednafen
      snes9x
      pcsx2
      godot
    ];
  };
}
