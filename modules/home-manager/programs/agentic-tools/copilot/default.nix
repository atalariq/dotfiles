{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  options.dotfiles.programs.copilot.enable = lib.mkEnableOption "GitHub Copilot CLI";

  config = lib.mkIf config.dotfiles.programs.copilot.enable {
    home.packages = [
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.copilot-cli
    ]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      pkgs.bubblewrap
      pkgs.slirp4netns
      pkgs.util-linux
      pkgs.iptables-nftables-compat
    ];

    # Copilot owns config.json and permissions-config.json. Seed only the shared
    # defaults into a writable profile when it does not exist yet.
    xdg.configFile."dotfiles/templates/copilot.json".source = ./settings.json;
    # Native MCP state remains writable; provisioning creates this seed only when absent.
    xdg.configFile."dotfiles/templates/copilot-mcp.json".text = builtins.toJSON {
      mcpServers =
        lib.optionalAttrs config.dotfiles.programs.codegraph.enable {
          codegraph = {
            type = "local";
            command = "codegraph";
            args = [
              "serve"
              "--mcp"
            ];
            tools = [ "*" ];
          };
        }
        // lib.optionalAttrs config.dotfiles.programs.agent-browser.enable {
          agent-browser = {
            type = "local";
            command = "agent-browser";
            args = [ "mcp" ];
            tools = [ "*" ];
          };
        };
    };

  };
}
