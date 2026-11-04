# Lab Mac mini: GUI apps are Homebrew casks, Nix supplies CLI/TUI only.
{ pkgs }:
let
  common = import ../../../modules/packages/common.nix { inherit pkgs; };
in
{
  stacks = [
    "node"
    "python"
  ];

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

  cli = common.cli;
}
