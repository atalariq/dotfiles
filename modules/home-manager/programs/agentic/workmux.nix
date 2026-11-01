{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  options.dotfiles.programs.agentic.workmux.enable = lib.mkEnableOption "workmux";
  config = lib.mkIf config.dotfiles.programs.agentic.workmux.enable {
    home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.workmux ];
  };
}
