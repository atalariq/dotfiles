# GUI apps are Homebrew casks on macOS. Home Manager keeps config only.
{ pkgs }:
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

  cli = with pkgs; [ glab ];
}
