{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
{

  options.dotfiles.programs.claude.enable = lib.mkEnableOption "claude configuration";

  config = lib.mkIf config.dotfiles.programs.claude.enable {

    home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code ];
    # Claude rewrites permissions, sandbox state and MCP entries in its own
    # settings file. Seed only a shared default when absent, then leave it native.
    xdg.configFile."dotfiles/templates/claude.json".source = ./template.json;

    # Native MCP state remains writable; provisioning creates this seed only when absent.
    xdg.configFile."dotfiles/templates/claude-mcp.json" =
      lib.mkIf config.dotfiles.programs.codegraph.enable
        {
          text = builtins.toJSON {
            mcpServers.codegraph = {
              type = "stdio";
              command = "codegraph";
              args = [
                "serve"
                "--mcp"
              ];
            };
          };
        };

  };
}
