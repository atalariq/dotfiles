{
  config,
  pkgs,
  lib,
  dotfilesLib,
  ...
}:
{

  options.dotfiles.terminal.bat.enable = lib.mkEnableOption "bat configuration";

  config = lib.mkIf config.dotfiles.terminal.bat.enable {

    programs.bat.enable = true;

  };
}
