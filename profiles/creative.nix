{ pkgs, ... }:
{
  # ThinkPad selection. These are packages, not one-line enable modules.
  home.packages = with pkgs; [
    (callPackage ../packages/concat.nix { })
    kdePackages.kdenlive
    reaper
    inkscape
    gimp
    blender
    godot
    nicotine-plus
    figma-linux
    (callPackage ../packages/pencil-dev.nix { })
  ];
}
