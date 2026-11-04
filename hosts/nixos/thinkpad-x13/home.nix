{ config, pkgs, ... }:
let
  apps = import ./apps.nix { inherit pkgs; };
in
{
  imports = [
    ../../../modules/home-manager
  ];
  home = {
    # CLI tools stay in the Home Manager profile; system packages live in
    # apps.nix and are installed by default.nix.
    packages = apps.cli;
    sessionVariables.DOTFILES_HOST = "thinkpad-x13";
    homeDirectory = "/home/atalariq";
    stateVersion = "26.05";
    # Bitwarden sets PR_SET_DUMPABLE, which makes the Secret portal reject
    # /proc/<pid>/root. Use the native Secret Service path instead so the
    # biometric key can be stored and the system-auth option can appear.
    file.".local/bin/bitwarden".source = pkgs.writeShellScript "bitwarden-no-portal" ''
      export GTK_USE_PORTAL=0
      exec /run/current-system/sw/bin/bitwarden "$@"
    '';
  };
  dotfiles = {
    deployment.liveApps = [
      "espanso"
      "vim"
      "neovim"
      "fish"
      "kitty"
      "television"
      "umbriel"
      "noctalia"
    ];
    appearance = {
      enable = true;
      gui = true;
    };
    desktop = {
      defaults.enable = true;
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
      # One list, two readers: apps.nix also feeds the system IDE assertion.
      development.stacks = apps.stacks;
      cli = {
        enable = true;
        terminal-tools.enable = true;
        aria2.enable = true;
        atuin.enable = true;
        gh.enable = true;
        mpd.enable = true;
        neovim = {
          enable = true;
          profile = "full";
        };
        television.enable = true;
        typst.enable = true;
        yazi.enable = true;
        yt-dlp.enable = true;
      };
      # GUI applications are selected in apps.nix (system-owned). Home Manager
      # only keeps the modules that own configuration or a service.
      gui = {
        brave-origin.enable = true;
        espanso.enable = true;
        kitty.enable = true;
        obs-studio.enable = true;
        zotero.enable = true;
      };
      # Per-tool opt-in (no umbrella): codex/claude stay off until there is a
      # subscription for them.
      agentic = {
        core.enable = true;
        experimental.enable = true;
        agent-browser.enable = true;
        hermes.enable = true;
        opencode.enable = true;
      };
      development = {
        devenv.enable = true;
        direnv.enable = true;
        mise.enable = true;
        podman.enable = true;
      };
    };
    services = {
      syncthing.enable = true;
      secrets = {
        enable = true;
        keyFile = "${config.home.homeDirectory}/.config/sops/age/thinkpad-x13.txt";
        files.aiProviders = ../../../secrets/thinkpad-x13/ai-providers.sops.yaml;
        files.credentials = ../../../secrets/thinkpad-x13/credentials.sops.yaml;
      };
    };
  };
}
