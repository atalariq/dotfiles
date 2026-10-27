{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  options.dotfiles.programs.agy.enable = lib.mkEnableOption "Google Antigravity CLI";

  config = lib.mkIf config.dotfiles.programs.agy.enable {
    home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.antigravity-cli ];

    # agy normalizes settings.json on startup and stores its own permission
    # decisions there. Seed the schema only; account state stays writable.
    xdg.configFile."dotfiles/templates/agy.json".text = builtins.toJSON {
      "$schema" = "https://antigravity.google/schemas/v1/settings.json";
    };
    # Merge only this named entry into the writable native MCP map. agy owns
    # unrelated servers and any authentication associated with them.
    xdg.configFile."dotfiles/templates/agy-mcp.json".text = builtins.toJSON {
      mcpServers =
        lib.optionalAttrs config.dotfiles.programs.codegraph.enable {
          codegraph = {
            command = "codegraph";
            args = [
              "serve"
              "--mcp"
            ];
          };
        }
        // lib.optionalAttrs config.dotfiles.programs.agent-browser.enable {
          agent-browser = {
            command = "agent-browser";
            args = [ "mcp" ];
          };
        };
    };
  };
}
