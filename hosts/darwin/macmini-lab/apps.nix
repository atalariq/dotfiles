# Lab Mac mini: GUI apps are Homebrew casks, Nix supplies CLI/TUI only.
_: {
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

  # Shared CLI floor comes from modules/packages/cli.nix.
  cli = [ ];
}
