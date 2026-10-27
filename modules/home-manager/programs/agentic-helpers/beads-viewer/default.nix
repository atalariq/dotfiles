{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  options.dotfiles.programs.beads-viewer.enable = lib.mkEnableOption "the bv Beads viewer";
  config = lib.mkIf config.dotfiles.programs.beads-viewer.enable {
    # `bv` reads the store br uses; this module installs the binary only.
    home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.beads-viewer ];
  };
}
