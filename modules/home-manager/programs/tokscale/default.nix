{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  options.dotfiles.programs.tokscale.enable = lib.mkEnableOption "tokscale";
  config = lib.mkIf config.dotfiles.programs.tokscale.enable {
    home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.tokscale ];
  };
}
