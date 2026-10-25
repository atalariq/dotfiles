{
  config,
  lib,
  pkgs,
  inputs,
  dotfilesLib,
  neovimPackage ? null,
  ...
}:
let
  # Only native files can use live mode. Plugin/tool changes always rebuild.
  editor =
    if config.dotfiles.deployment.mode == "live" then
      import ../../../../packages/neovim.nix {
        inherit inputs pkgs;
        runtime = dotfilesLib.source ./config;
      }
    else if neovimPackage != null then
      neovimPackage
    else
      import ../../../../packages/neovim.nix { inherit inputs pkgs; };
in
{
  options.dotfiles.programs.neovim.enable = lib.mkEnableOption "nvf workstation editor";
  config = lib.mkIf config.dotfiles.programs.neovim.enable {
    home.packages = [ editor ];
    home.sessionVariables = {
      DOTFILES_NVIM_SOURCE = "${config.dotfiles.deployment.checkout}/modules/home-manager/programs/neovim/config";
      EDITOR = "nvim";
      VISUAL = "nvim";
      GIT_EDITOR = "nvim";
    };
    xdg.configFile."vale/.vale.ini".source = dotfilesLib.source ./vale.ini;
  };
}
