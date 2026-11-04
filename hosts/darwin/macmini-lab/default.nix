{ pkgs, ... }:
{
  imports = [ ../../../modules/darwin ];

  # The lab owns the hostname; only the local account and platform are fixed.
  system.primaryUser = "praktikan";
  users.users.praktikan = {
    home = "/Users/praktikan";
    shell = pkgs.fish;
  };
  nixpkgs.hostPlatform = "aarch64-darwin";
  system.stateVersion = 6;

  # GUI/native macOS apps are Homebrew-owned. Keep Nix limited to CLI/TUI
  # tooling in the Home Manager profile.
  homebrew = {
    enable = true;
    casks = [
      "kitty"
      "android-studio"
      "android-platform-tools"
      "helium-browser"
      "google-chrome"
      "bitwarden"
      "discord"
      "slack"
      "obsidian"
      "orbstack"
      "localsend"
    ];
  };
}
