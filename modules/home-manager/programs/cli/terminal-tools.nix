# Convenience aggregate for the CLI utilities that were previously one
# `dotfiles.programs.cli.terminal-tools` bundle. Each package keeps its own module and
# switch; this only flips their defaults so a host can opt in once and still
# disable a single tool.
{
  config,
  lib,
  ...
}:
let
  cfg = config.dotfiles.programs.cli.terminal-tools;
in
{
  options.dotfiles.programs.cli.terminal-tools.enable =
    lib.mkEnableOption "the CLI diagnostics/utility set (btop, fastfetch, dust, duf, hyperfine, tealdeer, typos, lazysql)";

  config = lib.mkIf cfg.enable {
    dotfiles.programs.cli = {
      btop.enable = lib.mkDefault true;
      fastfetch.enable = lib.mkDefault true;
      dust.enable = lib.mkDefault true;
      duf.enable = lib.mkDefault true;
      hyperfine.enable = lib.mkDefault true;
      tealdeer.enable = lib.mkDefault true;
      typos.enable = lib.mkDefault true;
      lazysql.enable = lib.mkDefault true;
    };
  };
}
