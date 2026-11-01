{
  config,
  pkgs,
  lib,
  dotfilesLib,
  ...
}:
let
  cfg = config.dotfiles.programs.cli.yt-dlp;
in
{

  options.dotfiles.programs.cli.yt-dlp = {
    enable = lib.mkEnableOption "yt-dlp configuration";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.yt-dlp;
    };
  };

  config = lib.mkIf config.dotfiles.programs.cli.yt-dlp.enable {
    home.packages = [ cfg.package ];
    xdg.configFile."yt-dlp/config".source = dotfilesLib.source ./config/yt-dlp/config;
    xdg.configFile."fish/conf.d/yt-dlp.fish" = lib.mkIf config.programs.fish.enable {
      source = dotfilesLib.sourceFor "fish" ./config/yt-dlp/fish.fish;
    };
  };
}
