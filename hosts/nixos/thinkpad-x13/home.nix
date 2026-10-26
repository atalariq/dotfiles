{ config, pkgs, ... }:
{
  imports = [
    ../../../modules/home-manager/common
  ];
  home = {
    sessionVariables.DOTFILES_HOST = "thinkpad-x13";
    homeDirectory = "/home/atalariq";
    stateVersion = "26.05";
    packages = with pkgs; [
      coreutils
      findutils
      gnugrep
      gnused
      diffutils
      wget
      gnutar
      unzip
      zip
      delta
      dust
      hyperfine
      tealdeer
      usage
      typos
      brave-origin
      google-chrome
      nautilus
      file-roller
      adwaita-icon-theme
      xdg-utils
      libsecret
      psmisc
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
      localsend
      scrcpy
      lazysql
      kdePackages.kdenlive
      wdisplays
      wl-mirror
      libva-utils
      inkscape
      gimp
      blender
      godot
      nicotine-plus
      figma-linux
      osu-lazer
      gzdoom
      mcpelauncher-ui-qt
      mgba
      mednafen
      snes9x
      pcsx2
      (callPackage ../../../modules/home-manager/programs/concat/package.nix { })
      (callPackage ../../../modules/home-manager/programs/pen/package.nix { })
    ];
  };
  programs = {
    atuin.enable = true;
    fzf.enable = true;
    yazi.enable = true;
    delta.enable = true;
    delta.enableGitIntegration = true;
    jujutsu.enable = true;
    television.enable = true;
    kitty.enable = true;
    fastfetch.enable = true;
    herdr.enable = true;
    lookapp.enable = true;
    jujutsu.settings.user = {
      name = "Atalariq Barra Hadinugraha";
      email = "atalariq.dev@outlook.com";
    };
    mangohud = {
      enable = true;
      enableSessionWide = false;
      settings = {
        fps = true;
        frame_timing = true;
        cpu_temp = true;
        gpu_temp = true;
      };
    };
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
  systemd.user.services.syncthing.Service.Environment = [ "STNODEFAULTFOLDER=1" ];
  dotfiles = {
    deployment.liveApps = [
      "espanso"
      "vim"
      "neovim"
      "hermes"
      "opencode"
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
      lazygit.enable = true;
      neovim.enable = true;
      typst.enable = true;
      rtk.enable = true;
      tirith.enable = true;
      opencode.enable = true;
      codex.enable = true;
      beads-rust.enable = true;
      freesmlauncher.enable = true;
      tokscale.enable = true;
      crit.enable = true;
      agent-browser.enable = true;
      codegraph.enable = true;
      git-ai = {
        enable = true;
        repositories = [ "https://github.com/atalariq/dotfiles.git" ];
      };
      git-surgeon.enable = true;
      nono.enable = true;
      workmux.enable = true;
      orca.enable = true;
      agy.enable = true;
      copilot.enable = true;
      claude.enable = true;
      espanso.enable = true;
      plane.enable = true;
      btop.enable = true;
      mpd.enable = true;
      rmpc.enable = true;
      mpv.enable = true;
      aria2.enable = true;
      yt-dlp.enable = true;
      obs-studio.enable = true;
      hermes.enable = true;
      omniroute.enable = true;
    };
    services.secrets = {
      enable = true;
      keyFile = "${config.home.homeDirectory}/.config/age/ssh-keys.txt";
      files.aiProviders = ../../../secrets/thinkpad-x13/ai-providers.sops.yaml;
    };
  };
}
