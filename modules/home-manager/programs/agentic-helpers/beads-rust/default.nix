{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.programs.beads-rust;
in
{
  options.dotfiles.programs.beads-rust = {
    enable = lib.mkEnableOption "Beads Rust project task tracking";
    directory = lib.mkOption {
      type = lib.types.addCheck lib.types.str (lib.hasPrefix "/");
      default = "${config.dotfiles.deployment.checkout}/.beads";
      description = "Shared dotfiles task directory; other projects retain native br discovery.";
    };
  };
  config = lib.mkIf cfg.enable {
    home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.beads-rust ];
    # Do not set BEADS_DIR globally: that would redirect unrelated projects.
    home.sessionVariables.DOTFILES_BEADS_DIR = cfg.directory;
  };
}
