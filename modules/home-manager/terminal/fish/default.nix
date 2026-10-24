{
  config,
  pkgs,
  lib,
  dotfilesLib,
  ...
}:
{

  options.dotfiles.terminal.fish.enable = lib.mkEnableOption "fish configuration";

  config = lib.mkIf config.dotfiles.terminal.fish.enable {

    home.packages = with pkgs; [
      fish
      miniserve
    ];
    # Keep Fish's directory writable for fish_variables and runtime state.
    xdg.configFile =
      (lib.mapAttrs'
        (
          name: _:
          lib.nameValuePair "fish/conf.d/${name}" {
            source = dotfilesLib.source (./config/conf.d + "/${name}");
          }
        )
        (
          lib.filterAttrs (name: _: name != "06-theme.fish" || !config.dotfiles.desktop.appearance.enable) (
            builtins.readDir ./config/conf.d
          )
        )
      )
      // {
        "fish/config.fish".source = dotfilesLib.source ./config/config.fish;
        "fish/functions".source = dotfilesLib.source ./config/functions;
        "fish/completions".source = dotfilesLib.source ./config/completions;
      };

  };
}
