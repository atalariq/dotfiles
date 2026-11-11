# Packages this workstation installs. GUI apps belong to the system so they
# integrate with the host (desktop entries, D-Bus services, portals); the
# matching Home Manager modules only write configuration.
#
# `stacks` is read by both layers: the system side asserts that every mapped
# stack has its JetBrains IDE here, Home Manager uses it for PATH toolchains
# and nvf's language modules.
{ pkgs }:
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
    ghostty
    nautilus
    file-roller
    vlc
    oculante
    readest
    koreader
    obs-studio
    obsidian
    nicotine-plus
    localsend
    scrcpy
    zotero
    zathura
    sioyek
    (pkgs.callPackage ../../../modules/packages/zaread.nix { })
    quickemu
    quickgui

    # Creative and productivity.
    # anki 26.09.4 fails to build offline in the current nixpkgs rev (its
    # hatchling/tomlkit build deps are not in the vendored cache); the binary
    # release is cached and one patch behind.
    anki-bin
    audacity
    blender
    (discord.override {
      withOpenASAR = true;
      withVencord = true;
    })
    figma-linux
    gimp
    inkscape
    libreoffice
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

    # IDEs to Try
    vscode
    zed-editor
  ];

  cli = with pkgs; [
    glab
    android-tools
    ffmpeg
    obs-cmd
  ];
}
