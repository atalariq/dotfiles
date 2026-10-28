{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  options.dotfiles.programs.agent-browser.enable = lib.mkEnableOption "agent-browser";
  config = lib.mkIf config.dotfiles.programs.agent-browser.enable {
    home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.agent-browser ];
  };
}
