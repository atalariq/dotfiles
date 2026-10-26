{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  # Gemini CLI is separate from agy. Consumer account access migrated to agy;
  # enable this only for supported Gemini API / Vertex AI credentials.
  options.dotfiles.programs.gemini.enable = lib.mkEnableOption "Gemini CLI";

  config = lib.mkIf config.dotfiles.programs.gemini.enable {
    home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.gemini-cli ];
    xdg.configFile."dotfiles/templates/gemini.json".source = ./settings.json;
  };
}
