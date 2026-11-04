{ config, pkgs, ... }:
{
  imports = [
    ../../../modules/home-manager
  ];
  home = {
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
      development.stacks = [
        "node"
        "bun"
        "python"
        "go"
        "rust"
        "cc"
        # gate-only (no PATH runtime): drives nvf languages + PhpStorm.
        "php"
        "vue"
        "sql"
      ];
      cli = {
        enable = true;
        terminal-tools.enable = true;
        aria2.enable = true;
        atuin.enable = true;
        gh.enable = true;
        glab.enable = true;
        mpd.enable = true;
        neovim.enable = true;
        television.enable = true;
        typst.enable = true;
        yazi.enable = true;
        yt-dlp.enable = true;
      };
      gui = {
        workstation.enable = true;
        jellyfin.enable = true;
      };
      # Per-tool opt-in (no umbrella): codex/claude stay off until there is a
      # subscription for them; git-ai stays off as a documented experiment.
      agentic = {
        core.enable = true;
        experimental.enable = true;
        agy.enable = true;
        agent-browser.enable = true;
        hermes.enable = true;
        opencode.enable = true;
        tokscale.enable = true;
        workmux.enable = true;
      };
      development = {
        android.enable = true;
        devenv.enable = true;
        direnv.enable = true;
        # IDEs derive from development.stacks above: node/bun->webstorm,
        # go->goland, rust->rustrover, php->phpstorm. python/cc intentionally
        # have no mapping (Neovim covers them).
        jetbrains.enable = true;
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
