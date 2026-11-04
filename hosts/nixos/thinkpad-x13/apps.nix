# Packages this workstation installs. GUI apps belong to the system so they
# integrate with the host (desktop entries, D-Bus services, portals); the
# matching Home Manager modules only write configuration.
#
# `stacks` is read by both layers: the system side asserts that every mapped
# stack has its JetBrains IDE here, Home Manager uses it for PATH toolchains
# and nvf's language modules.
{ pkgs }:
let
  common = import ../../../modules/packages/common.nix { inherit pkgs; };
in
{
  stacks = [
    "node"
    "bun"
    "python"
    "go"
    "rust"
    "cc"
    "php"
    "vue"
    "sql"
  ];

  gui = with pkgs; [
    # Browsers, files and media.
    brave-origin
    google-chrome
    kitty
    nautilus
    file-roller
    miro
    vlc
    oculante
    readest
    obs-studio
    obsidian
    nicotine-plus
    localsend
    scrcpy
    jellyfin-desktop
    zotero

    # Creative and productivity.
    anki
    audacity
    blender
    discord
    figma-linux
    gimp
    inkscape
    kdePackages.kdenlive
    slack
    wdisplays
    wl-mirror
    libva-utils

    # Editors derived from the stacks above (keep in sync; eval asserts it).
    jetbrains.webstorm
    jetbrains.goland
    jetbrains.rust-rover
    jetbrains.phpstorm

    # Android (studio is GUI; the platform tools are CLI).
    android-studio
  ];

  cli =
    common.cli
    ++ common.forge
    ++ (with pkgs; [
      android-tools
      ffmpeg
      obs-cmd
    ]);
}
