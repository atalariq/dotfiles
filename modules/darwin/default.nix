{ ... }:
{
  # Host-independent macOS baseline. Linux services never enter this module graph.
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  programs.fish.enable = true;
}
