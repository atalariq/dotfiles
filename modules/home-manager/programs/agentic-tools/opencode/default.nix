{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
let
  format = pkgs.formats.json { };
  native = builtins.fromJSON (builtins.readFile ./config/opencode.jsonc);
  seed = lib.recursiveUpdate (builtins.fromJSON (builtins.readFile ./config/providers.json)) native;
in
{

  options.dotfiles.programs.opencode.enable = lib.mkEnableOption "opencode configuration";

  config = lib.mkIf config.dotfiles.programs.opencode.enable {

    # V2 schemas require opencode2; the opencode attribute still packages V1.
    home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode2 ];
    # Native CLI/MCP commands rewrite this file, so keep the working profile
    # writable and seed a minimal default (direct DeepSeek + opt-out of sharing).
    xdg.configFile."dotfiles/templates/opencode.jsonc".source = format.generate "opencode.json" (
      lib.recursiveUpdate seed {
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
      }
    );

  };
}
