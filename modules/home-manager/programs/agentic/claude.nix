{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
{

  options.dotfiles.programs.agentic.claude.enable = lib.mkEnableOption "claude configuration";

  config = lib.mkIf config.dotfiles.programs.agentic.claude.enable {

    home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code ];
    # Claude rewrites permissions, sandbox state and MCP entries in its own
    # settings file. Seed only a shared default when absent, then leave it native.
    xdg.configFile."dotfiles/templates/claude.json".source = ./config/claude/template.json;

    # Native MCP state remains writable; provisioning creates this seed only when absent.
    xdg.configFile."dotfiles/templates/claude-mcp.json".text = builtins.toJSON {
      mcpServers =
        lib.optionalAttrs config.dotfiles.programs.agentic.core.enable {
          codegraph = {
            type = "stdio";
            command = "codegraph";
            args = [
              "serve"
              "--mcp"
            ];
          };
        }
        // lib.optionalAttrs config.dotfiles.programs.agentic.agent-browser.enable {
          agent-browser = {
            type = "stdio";
            command = "agent-browser";
            args = [ "mcp" ];
          };
        };
    };

  };
}
