{ pkgs, ... }:
{
  imports = [
    ../../../modules/home-manager
    ../../../profiles/cli.nix
    ../../../profiles/development.nix
    ../../../profiles/gui.nix
    ../../../profiles/creative.nix
    ../../../profiles/gaming.nix
  ];
  home = {
    username = "atalariq";
    homeDirectory = "/home/atalariq";
    stateVersion = "26.05";
  };
  xdg.enable = true;
  programs.home-manager.enable = true;
  programs = {
    git.settings.user = {
      name = "Atalariq Barra Hadinugraha";
      email = "atalariq.dev@outlook.com";
      username = "atalariq";
    };
    jujutsu.settings.user = {
      name = "Atalariq Barra Hadinugraha";
      email = "atalariq.dev@outlook.com";
    };
    fastfetch.enable = true;
    herdr.enable = true;
    lookapp.enable = true;
  };
  services.syncthing = {
    enable = true;
    guiAddress = "127.0.0.1:8384";
    overrideDevices = false;
    overrideFolders = false;
    settings = {
      folders = { };
      options.startBrowser = false;
    };
  };
  # No default Sync folder or implicit sharing. Runtime identity stays writable.
  systemd.user.services.syncthing.Service.Environment = [ "STNODEFAULTFOLDER=1" ];
  dotfiles = {
    desktop = {
      mango.enable = true;
      mango.monitorConfig = "monitor_rule = name:eDP-1,width:1920,height:1200,refresh:60,x:0,y:0,scale:1.25,vrr:0,rr:0";
      noctalia.enable = true;
      helpers.enable = true;
    };
    programs = {
      espanso.enable = true;
      plane.enable = true;
      linear.enable = true;
      btop.enable = true;
      status.enable = true;
      vimv.enable = true;
      mpd.enable = true;
      rmpc.enable = true;
      mpv.enable = true;
      aria2.enable = true;
      yt-dlp.enable = true;
      jellyfin-helper.enable = true;
      obs-studio.enable = true;
      capture.enable = true;
      hermes.enable = true;
      omniroute.enable = true;
    };
    services.secrets.enable = true;
    programs.rsync.enable = true;
  };
  home.packages = with pkgs; [
    sops
    age
    gnupg
    brave-origin
    google-chrome
    nautilus
    file-roller
    adwaita-icon-theme
    xdg-utils
    libsecret
    psmisc
    bitwarden-desktop
    discord
    slack
    anki
    obsidian
    readest
    ncmpcpp
    android-studio
    podman
    podman-compose
    jetbrains.rust-rover
    jetbrains.phpstorm
    jetbrains.goland
  ];
  # Zotero is intentionally omitted: opt in by adding pkgs.zotero here.
}
