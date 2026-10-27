{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  options.dotfiles.programs.hermes.enable =
    lib.mkEnableOption "Hermes CLI with direct provider configuration";
  config = lib.mkIf config.dotfiles.programs.hermes.enable {
    home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.hermes-agent ];
    # Hermes rewrites its native profile. Keep it writable and seed/merge only
    # selected preferences; authentication, sessions and local toolsets survive.
    xdg.configFile."dotfiles/templates/hermes.yaml".text =
      builtins.readFile ./config/config.yaml
      + lib.optionalString config.dotfiles.programs.codegraph.enable ''
        mcp_servers:
          codegraph:
            command: codegraph
            args: [serve, --mcp]
      '';
  };
}
