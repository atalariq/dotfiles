# Convenience aggregate for the CLI utilities that were previously one
# `dotfiles.programs.cli.terminal-tools` bundle. Tools with native Home Manager
# modules keep their switch; package-only tools are listed directly so adding
# or removing one never needs a new file.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.programs.cli.terminal-tools;
  cli = config.dotfiles.programs.cli;
in
{
  options.dotfiles.programs.cli.terminal-tools.enable =
    lib.mkEnableOption "the CLI diagnostics/utility set (btop, fastfetch, dust, duf, hyperfine, tealdeer, typos)";

  config = lib.mkIf (cli.enable && cfg.enable) {
    dotfiles.programs.cli = {
      btop.enable = lib.mkDefault true;
      fastfetch.enable = lib.mkDefault true;
    };

    home.packages = with pkgs; [
      dust
      duf
      hyperfine
      tealdeer
      typos
    ];
  };
}
