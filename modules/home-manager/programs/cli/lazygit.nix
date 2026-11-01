{
  config,
  lib,
  pkgs,
  dotfilesLib,
  ...
}:
let
  cfg = config.dotfiles.programs.cli.lazygit;
  cli = config.dotfiles.programs.cli;
in
{
  options.dotfiles.programs.cli.lazygit = {
    enable = lib.mkEnableOption "lazygit with the shared native configuration" // {
      default = true;
    };
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.lazygit;
      description = "lazygit package to install.";
    };
  };

  config = lib.mkIf (cli.enable && cfg.enable) {
    home.packages = [ cfg.package ];
    xdg.configFile."lazygit".source = dotfilesLib.themedDirectory ./config/lazygit;
  };
}
