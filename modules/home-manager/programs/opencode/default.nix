{
  config,
  pkgs,
  lib,
  ...
}:
let
  settings = builtins.fromJSON (builtins.readFile ./config/opencode.jsonc);
  format = pkgs.formats.json { };
in
{

  options.dotfiles.programs.opencode.enable = lib.mkEnableOption "opencode configuration";

  config = lib.mkIf config.dotfiles.programs.opencode.enable {

    home.packages = with pkgs; [ opencode ];
    # Keep the directory writable for local plugins and their dependencies.
    xdg.configFile."opencode/opencode.jsonc".source = format.generate "opencode.json" (
      lib.recursiveUpdate settings {
        providers.omniroute.settings.apiKey = "{file:${config.xdg.configHome}/sops-nix/secrets/opencode-key}";
      }
    );
    xdg.configFile."opencode/cli.json".source = ./config/cli.json;

  };
}
