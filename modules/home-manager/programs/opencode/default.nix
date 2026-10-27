{
  config,
  inputs,
  pkgs,
  lib,
  dotfilesLib,
  ...
}:
let
  cfg = config.dotfiles.programs.opencode;
  format = pkgs.formats.json { };
  native = builtins.fromJSON (builtins.readFile ./config/opencode.jsonc);
  seed = lib.recursiveUpdate (builtins.fromJSON (builtins.readFile ./config/providers.json)) native;
in
{

  options.dotfiles.programs.opencode = {
    enable = lib.mkEnableOption "opencode configuration";
    gatewayUrl = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Optional OmniRoute API endpoint; null keeps direct providers only.";
    };
  };

  config = lib.mkIf config.dotfiles.programs.opencode.enable {

    # V2 schemas require opencode2; the opencode attribute still packages V1.
    home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode2 ];
    # Keep the directory writable for local plugins and their dependencies.
    # /connect stores provider credentials in native writable auth state.
    # DeepSeek is direct; OpenRouter and any gateway are explicit model choices.
    # Native CLI/MCP commands rewrite these settings. Keep the working profile
    # writable and provide a seed, rather than replacing its account/UI choices.
    xdg.configFile."dotfiles/templates/opencode.jsonc".source = format.generate "opencode.json" (
      lib.recursiveUpdate seed {
        providers = lib.optionalAttrs (cfg.gatewayUrl != null) {
          omniroute = (builtins.fromJSON (builtins.readFile ./config/gateway.json)) // {
            settings.baseURL = cfg.gatewayUrl;
          };
        };
        mcp.servers = lib.optionalAttrs config.dotfiles.programs.codegraph.enable {
          codegraph = {
            type = "local";
            command = [
              "codegraph"
              "serve"
              "--mcp"
            ];
          };
        };
        permissions = [
          {
            action = "*";
            resource = "*";
            effect = "allow";
          }
          {
            action = "external_directory";
            resource = "*";
            effect = "ask";
          }
        ]
        ++ native.permissions
        ++ lib.optionals config.dotfiles.programs.beads-rust.enable (
          (map
            (resource: {
              action = "external_directory";
              inherit resource;
              effect = "allow";
            })
            [
              config.dotfiles.programs.beads-rust.directory
              "${config.dotfiles.programs.beads-rust.directory}/**"
            ]
          )
          ++
            map
              (command: {
                action = "shell";
                resource = "br ${command}*";
                effect = "allow";
              })
              [
                "ready"
                "show"
                "list"
                "blocked"
                "coordination status"
                "update"
                "comments"
                "close"
                "sync --flush-only"
                "sync --import-only"
              ]
          ++ [
            {
              action = "shell";
              resource = "br *--force*";
              effect = "ask";
            }
          ]
        );
      }
    );
    xdg.configFile."dotfiles/templates/opencode-cli.json".source =
      dotfilesLib.sourceFor "opencode" ./config/cli.json;

  };
}
