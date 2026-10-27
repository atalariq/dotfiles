{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.dotfiles.programs.glab.enable = lib.mkEnableOption "glab configuration";

  config = lib.mkIf config.dotfiles.programs.glab.enable {
    # Authentication and runtime state stay writable; install the binary only.
    home.packages = with pkgs; [ glab ];
  };
}
