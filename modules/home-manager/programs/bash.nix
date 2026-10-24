{
  config,
  lib,
  pkgs,
  ...
}:
{
  home.sessionPath = lib.mkIf config.programs.bash.enable [
    "${config.home.homeDirectory}/.local/bin"
  ];
}
