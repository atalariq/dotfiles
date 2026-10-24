{ ... }: {
  imports = [
    ./capture.nix
    ./jellyfin-helper.nix
    ./mpd
    ./mpv
    ./obs-studio
    ./packages.nix
    ./rmpc
  ];
}
