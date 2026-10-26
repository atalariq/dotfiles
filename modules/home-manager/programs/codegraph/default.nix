{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  options.dotfiles.programs.codegraph.enable = lib.mkEnableOption "codegraph";
  config = lib.mkIf config.dotfiles.programs.codegraph.enable {
    home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codegraph ];
  };
}
