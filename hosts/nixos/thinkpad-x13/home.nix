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
    # Launch the wrapper from autostart and the application menu, not the
    # store binary. The portal path rejects /proc/<pid>/root and hides the
    # system-authentication (biometric) option.
    file.".config/autostart/bitwarden.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Bitwarden
      Comment=Bitwarden startup script
      Exec=${config.home.homeDirectory}/.local/bin/bitwarden --autostart
      StartupNotify=false
      Terminal=false
    '';
    file.".local/share/applications/bitwarden.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Bitwarden
      Comment=Password manager
      Exec=${config.home.homeDirectory}/.local/bin/bitwarden %U
      Icon=bitwarden
      Terminal=false
      Categories=Utility;Security;
      MimeType=x-scheme-handler/bitwarden;
      StartupNotify=true
    '';
  };
  # Syncthing keeps its config, device identity and folder list in the native
  # writable location; the module supplies the service, not a declarative
  # device list that would fight the UI every time I pair a phone.
  services.syncthing.enable = true;
  dotfiles = {
    deployment.liveApps = [
      "espanso"
      "vim"
      "neovim"
      "fish"
      "ghostty"
      "kitty"
      "tmux"
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
        aria2.enable = true;
        atuin.enable = true;
        btop.enable = true;
        fastfetch.enable = true;
        gh.enable = true;
        mpd.enable = true;
        navidrome-clients = {
          enable = true;
          ratune.enable = true;
          navibeat.enable = true;
        };
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
        ghostty.enable = true;
        kitty.enable = true;
        obs-studio.enable = true;
        zotero.enable = true;
      };
      # Per-tool opt-in (no umbrella): claude stays off until there is a
      # subscription for it.
      agentic = {
        core.enable = true;
        experimental.enable = true;
        agent-browser.enable = true;
        hermes.enable = true;
        opencode.enable = true;
        codex.enable = true;
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
