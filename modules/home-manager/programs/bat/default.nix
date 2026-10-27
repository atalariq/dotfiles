{
  config,
  lib,
  ...
}:
{

  options.dotfiles.programs.bat.enable = lib.mkEnableOption "bat configuration";

  config = lib.mkIf config.dotfiles.programs.bat.enable {

    programs.bat.enable = true;

  };
}
