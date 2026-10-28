{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [ inputs.nix-index-database.homeModules.nix-index ];

  options.dotfiles.programs.nix.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Nix tooling";
  };

  config = lib.mkIf config.dotfiles.programs.nix.enable {
    programs.nix-index = {
      enable = true;
      enableFishIntegration = config.programs.fish.enable;
    };

    # `comma` is owned by nix-index-database, not by programs.nix-index.
    programs.nix-index-database.comma.enable = true;

    home.packages = with pkgs; [
      nix-output-monitor # nom
      dix # nix-diff
      devenv
    ];
  };
}
