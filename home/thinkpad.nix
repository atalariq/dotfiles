{ pkgs, ... }:
{
  imports = [
    ./default.nix
    ./mango
    ./noctalia
    ./kitty
    ./atuin
    ./btop
    ./mpd
    ./rmpc
    ./mpv
    ./aria2
    ./yt-dlp
    ./obs-studio
    ./espanso
    ./fastfetch
    ./herdr
    ./helpers.nix
    # ./omniroute  # Optional: provide a verified image pin before enabling.
  ];

  home.packages = with pkgs; [
    anki
    brave-origin
    google-chrome
    nautilus
    obsidian
    slack
    android-studio
    libsecret
    file-roller
    adwaita-icon-theme
    xdg-utils
    psmisc
    brightnessctl
    satty
    ripdrag
    gpu-screen-recorder
    (tesseract.override {
      enableLanguages = [
        "eng"
        "ind"
      ];
    })
  ];
}
