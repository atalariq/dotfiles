{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.dotfiles.programs.opencode;
  format = pkgs.formats.json { };
in
{

  options.dotfiles.programs.opencode = {
    enable = lib.mkEnableOption "opencode configuration";
    gatewayUrl = lib.mkOption {
      type = lib.types.str;
      default = "http://127.0.0.1:20128/v1";
      description = "Reachable OmniRoute API endpoint; remote hosts need a secure gateway connection.";
    };
  };

  config = lib.mkIf config.dotfiles.programs.opencode.enable {

    # V2 schemas require opencode2; the opencode attribute still packages V1.
    home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode2 ];
    # Keep the directory writable for local plugins and their dependencies.
    # /connect stores the gateway client key in native writable auth state.
    # OMNIROUTE_API_KEY is also supported; never reuse the upstream provider key.
    xdg.configFile."opencode/opencode.jsonc".source = format.generate "opencode.json" (
      lib.recursiveUpdate (builtins.fromJSON (builtins.readFile ./config/opencode.jsonc)) {
        providers.omniroute.settings.baseURL = cfg.gatewayUrl;
      }
    );
    xdg.configFile."opencode/cli.json".source = ./config/cli.json;

  };
}
