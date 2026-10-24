{
  config,
  lib,
  pkgs,
  inputs,
  dotfilesLib,
  ...
}:
{
  options.dotfiles.programs.hermes.enable = lib.mkEnableOption "Hermes interactive CLI";
  config = lib.mkIf config.dotfiles.programs.hermes.enable {
    home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.hermes-agent ];
    home.file.".hermes/config.yaml".source = dotfilesLib.source ./config/config.yaml;
    dotfiles.services.secrets.applications.hermes = {
      DEEPSEEK_API_KEY = "DEEPSEEK_API_KEY_HERMES";
      OPENROUTER_API_KEY = "OPENROUTER_API_KEY";
      EXA_API_KEY = "EXA_API_KEY";
      FIRECRAWL_API_KEY = "FIRECRAWL_API_KEY";
    };
    assertions = [
      {
        assertion = config.dotfiles.services.secrets.enable;
        message = "Hermes requires dotfiles.services.secrets.enable for its runtime credentials.";
      }
    ];
    # Launch hermes-with-secrets hermes. No background gateway is installed.
  };
}
