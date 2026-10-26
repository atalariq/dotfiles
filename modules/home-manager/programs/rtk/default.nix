{
  config,
  inputs,
  pkgs,
  lib,
  dotfilesLib,
  ...
}:
{

  options.dotfiles.programs.rtk.enable = lib.mkEnableOption "rtk configuration";

  config = lib.mkIf config.dotfiles.programs.rtk.enable {

    home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.rtk ];
    xdg.configFile."rtk" = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      source = dotfilesLib.source ./config;
    };
    # RTK uses the native macOS directory for both config and writable tracking.
    # Link individual settings, leaving its database and recall files writable.
    home.file = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      "Library/Application Support/rtk/config.toml".source = dotfilesLib.source ./config/config.toml;
      "Library/Application Support/rtk/filters.toml".source = dotfilesLib.source ./config/filters.toml;
    };

  };
}
