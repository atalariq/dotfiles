{ pkgs, ... }:
{
  imports = [ ../../../modules/darwin ];
  networking.hostName = "macpro-m4";
  system.primaryUser = "atalariq";
  users.users.atalariq = {
    home = "/Users/atalariq";
    shell = pkgs.fish;
  };
  nixpkgs.hostPlatform = "aarch64-darwin";
  system.stateVersion = 6;
  homebrew = {
    enable = true;
    casks = [
      "google-chrome"
      "brave-browser"
      "bitwarden"
      "discord"
      "slack"
      "obsidian"
      "localsend"
      "linear"
      "flutter"
      "android-studio"
    ];
    brews = [
      "dart"
    ];
  };
}
