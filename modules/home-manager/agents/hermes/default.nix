{
  config,
  lib,
  inputs,
  dotfilesLib,
  ...
}:
{
  options.dotfiles.agents.hermes.enable = lib.mkEnableOption "Hermes interactive CLI";
  config = lib.mkIf config.dotfiles.agents.hermes.enable {
    home.packages = [ inputs.llm-agents.packages.x86_64-linux.hermes-agent ];
    home.file.".hermes/config.yaml".source = dotfilesLib.source ./config/config.yaml;
    dotfiles.security.secrets.applications.hermes = {
      DEEPSEEK_API_KEY = "DEEPSEEK_API_KEY_HERMES";
      OPENROUTER_API_KEY = "OPENROUTER_API_KEY";
      EXA_API_KEY = "EXA_API_KEY";
      FIRECRAWL_API_KEY = "FIRECRAWL_API_KEY";
    };
    assertions = [
      {
        assertion = config.dotfiles.security.secrets.enable;
        message = "Hermes requires dotfiles.security.secrets.enable for its runtime credentials.";
      }
    ];
    # Launch hermes-with-secrets hermes. No background gateway is installed.
  };
}
