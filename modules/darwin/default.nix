{ config, lib, ... }:
{
  imports = [ ../nix-cache.nix ];
  nix.enable = lib.mkDefault true;
  nix.settings = {
    experimental-features = lib.mkDefault [
      "nix-command"
      "flakes"
    ];
    # macOS has no wheel group; name the administrative user explicitly.
    trusted-users = lib.mkForce (
      lib.unique (
        [ "root" ]
        ++ lib.optional (
          config.system.primaryUser != null && config.system.primaryUser != ""
        ) config.system.primaryUser
      )
    );
  };
  programs.fish.enable = lib.mkDefault true;
  security.pam.services.sudo_local = {
    touchIdAuth = lib.mkDefault true;
    reattach = lib.mkDefault true;
  };
  homebrew.onActivation = {
    autoUpdate = lib.mkDefault false;
    upgrade = lib.mkDefault false;
    cleanup = lib.mkDefault "none";
  };
  system.defaults = {
    dock = {
      autohide = lib.mkDefault true;
      show-recents = lib.mkDefault false;
      mru-spaces = lib.mkDefault false;
      minimize-to-application = lib.mkDefault true;
      tilesize = lib.mkDefault 48;
    };
    finder = {
      AppleShowAllExtensions = lib.mkDefault true;
      ShowPathbar = lib.mkDefault true;
      ShowStatusBar = lib.mkDefault true;
      _FXSortFoldersFirst = lib.mkDefault true;
      FXPreferredViewStyle = lib.mkDefault "Nlsv";
    };
    NSGlobalDomain = {
      InitialKeyRepeat = lib.mkDefault 15;
      KeyRepeat = lib.mkDefault 2;
      ApplePressAndHoldEnabled = lib.mkDefault false;
      NSAutomaticSpellingCorrectionEnabled = lib.mkDefault false;
    };
  };
}
