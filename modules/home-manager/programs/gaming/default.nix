{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.dotfiles.bundles.gaming.enable = lib.mkEnableOption "the gaming package bundle";

  # Games, emulators, the Godot engine runtime and the Freesm Minecraft launcher.
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
      (pkgs.callPackage ./freesmlauncher.nix { })
    ];
  };
}
