{ config, ... }:
{
  imports = [
    ../../../modules/home-manager
  ];
  home = {
    sessionVariables.DOTFILES_HOST = "thinkpad-x13";
    homeDirectory = "/home/atalariq";
    stateVersion = "26.05";
  };
  dotfiles = {
    ai.enable = true;
    bundles = {
      "terminal-tools".enable = true;
      gui.enable = true;
      "jetbrains-ides".enable = true;
      gaming.enable = true;
      podman.enable = true;
    };
    deployment.liveApps = [
      "espanso"
      "vim"
      "neovim"
      "fish"
      "mango"
      "umbriel"
      "noctalia"
    ];
    appearance = {
      enable = true;
      gui = true;
    };
    desktop = {
      umbriel = {
        enable = true;
        settings.output.eDP-1 = {
          mode = "1920x1200@60";
          position = [
            0
            0
          ];
          scale = 1.25;
          workspaces = 9;
        };
      };
      mango = {
        enable = true;
        monitorRules = [ "name:eDP-1,width:1920,height:1200,refresh:60,x:0,y:0,scale:1.25,vrr:0,rr:0" ];
      };
      shelf.enable = true;
      noctalia.enable = true;
    };
    programs = {
      gh.enable = true;
      glab.enable = true;
      neovim.enable = true;
      typst.enable = true;
      atuin.enable = true;
      yazi.enable = true;
      television.enable = true;
      kitty.enable = true;
      fastfetch.enable = true;
      mangohud.enable = true;
      # Optional agent experiments remain independently opt-in. The AI module
      # installs clients and helpers without starting workers or hooks.
      agy.enable = true;
      espanso.enable = true;
      # mpd owns the daemon, rmpc client, MPRIS bridge and Last.fm scrobbler.
      mpd.enable = true;
      mpv.enable = true;
      aria2.enable = true;
      yt-dlp.enable = true;
      obs-studio.enable = true;
    };
    services = {
      syncthing.enable = true;
      secrets = {
        enable = true;
        keyFile = "${config.home.homeDirectory}/.config/age/ssh-keys.txt";
        files.aiProviders = ../../../secrets/thinkpad-x13/ai-providers.sops.yaml;
        files.credentials = ../../../secrets/thinkpad-x13/credentials.sops.yaml;
      };
    };
  };
}
