{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  options.dotfiles.programs.orca.enable = lib.mkEnableOption "orca";
  config = lib.mkIf config.dotfiles.programs.orca.enable {
    home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.orca ];
  };
}
