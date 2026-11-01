{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  options.dotfiles.programs.agentic.tokscale.enable = lib.mkEnableOption "tokscale";
  config = lib.mkIf config.dotfiles.programs.agentic.tokscale.enable {
    home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.tokscale ];
  };
}
