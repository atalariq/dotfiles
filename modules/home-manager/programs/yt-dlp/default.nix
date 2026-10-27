{
  config,
  pkgs,
  lib,
  dotfilesLib,
  ...
}:
{

  options.dotfiles.programs.yt-dlp.enable = lib.mkEnableOption "yt-dlp configuration";

  config = lib.mkIf config.dotfiles.programs.yt-dlp.enable {
    home.packages = [ pkgs.yt-dlp ];
    xdg.configFile."yt-dlp/config".source = dotfilesLib.source ./config/config;
    xdg.configFile."fish/conf.d/yt-dlp.fish" = lib.mkIf config.programs.fish.enable {
      source = dotfilesLib.sourceFor "fish" ./config/fish.fish;
    };
  };
}
