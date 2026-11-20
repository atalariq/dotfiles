{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.dotfiles.programs.cli.yt-dlp;
  source = import ../../lib/source.nix { inherit config; };
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
    xdg.configFile."yt-dlp/config".source =
      source ./config/yt-dlp/config "modules/home-manager/programs/cli/config/yt-dlp/config";
    xdg.configFile."fish/conf.d/yt-dlp.fish" = lib.mkIf config.programs.fish.enable {
      source = source ./config/yt-dlp/fish.fish "modules/home-manager/programs/cli/config/yt-dlp/fish.fish";
    };
  };
}
