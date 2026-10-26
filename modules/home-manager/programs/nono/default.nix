{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  options.dotfiles.programs.nono.enable = lib.mkEnableOption "nono";
  config = lib.mkIf config.dotfiles.programs.nono.enable {
    home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.nono ];
  };
}
