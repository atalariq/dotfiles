{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Development toolchain extras: containers, IDEs/database client and video
  # acceleration diagnostics. libva-utils is grouped here as a debugging tool
  # for the desktop stack; move it to media if that fits better.
  config = lib.mkIf config.dotfiles.bundles.dev.enable {
    home.packages = with pkgs; [
      podman
      podman-compose
      android-studio
      jetbrains.rust-rover
      jetbrains.phpstorm
      jetbrains.goland
      lazysql
      libva-utils
    ];
  };
}
