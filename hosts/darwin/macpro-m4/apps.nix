# GUI apps are Homebrew casks on macOS. Home Manager keeps config only.
{ pkgs }:
let
  common = import ../../../modules/packages/common.nix { inherit pkgs; };
in
{
  stacks = [
    "java"
    "kotlin"
    "dart"
  ];

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
    "kitty"
    "vlc"
  ];

  cli = common.cli ++ common.forge;
}
