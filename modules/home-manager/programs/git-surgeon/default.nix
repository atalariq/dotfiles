{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  options.dotfiles.programs.git-surgeon.enable = lib.mkEnableOption "git-surgeon";
  config = lib.mkIf config.dotfiles.programs.git-surgeon.enable {
    home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.git-surgeon ];
  };
}
