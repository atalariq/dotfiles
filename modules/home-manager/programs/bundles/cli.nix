{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Interactive terminal utilities that are not covered by a Home Manager
  # program option: search/inspection helpers, docs lookup, typo checking and
  # the local `concat` helper.
  config = lib.mkIf config.dotfiles.bundles.cli.enable {
    home.packages = with pkgs; [
      dust
      hyperfine
      tealdeer
      usage
      typos
      (pkgs.callPackage ../concat/package.nix { })
    ];
  };
}
