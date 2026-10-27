{
  config,
  lib,
  ...
}:
{
  programs.nix-search-tv = lib.mkIf config.programs.television.enable {
    enable = true;
    enableTelevisionIntegration = true;
  };
}
