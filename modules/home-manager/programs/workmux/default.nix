{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  options.dotfiles.programs.workmux.enable = lib.mkEnableOption "workmux";
  config = lib.mkIf config.dotfiles.programs.workmux.enable {
    home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.workmux ];
  };
}
