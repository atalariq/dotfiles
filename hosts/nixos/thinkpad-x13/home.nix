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
    dev.stacks = [
      "node"
      "bun"
      "python"
      "go"
      "rust"
      "cc"
    ];
    deployment.liveApps = [
      "espanso"
      "vim"
      "neovim"
      "fish"
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
          workspaces = 5;
        };
      };
      noctalia.enable = true;
    };
    programs = {
      core.enable = true;
      gui.enable = true;
      terminal.enable = true;
      aria2.enable = true;
      atuin.enable = true;
      espanso.enable = true;
      gh.enable = true;
      glab.enable = true;
      kitty.enable = true;
      mpd.enable = true;
      mpv.enable = true;
      neovim.enable = true;
      obs-studio.enable = true;
      television.enable = true;
      typst.enable = true;
      yazi.enable = true;
      yt-dlp.enable = true;
      development = {
        android.enable = true;
        devenv.enable = true;
        direnv.enable = true;
        jetbrains.enable = true;
        mise.enable = true;
        podman.enable = true;
      };
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
