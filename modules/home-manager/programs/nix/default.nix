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
    description = "Nix tooling: nix-index, nom, dix, comma and devenv";
  };

  config = lib.mkIf config.dotfiles.programs.nix.enable {
    programs.nix-index = {
      enable = true;
      enableFishIntegration = config.programs.fish.enable;
    };

    home.packages = with pkgs; [
      nix-output-monitor # nom
      dix # nix-diff
      comma
      devenv
    ];
  };
}
