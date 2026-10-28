{
  config,
  lib,
  pkgs,
  inputs,
  dotfilesLib,
  ...
}:
let
  # "neovim" is a live app: the runtime tree links back to the checkout, so
  # keymaps and options can be edited without a rebuild while everything build
  # time still comes from a generation.
  runtime = dotfilesLib.sourceFor "neovim" ./runtime;
in
{
  imports = [ inputs.nvf.homeManagerModules.nvf ];

  options.dotfiles.programs.neovim.enable = lib.mkEnableOption "nvf workstation editor";

  config = lib.mkIf config.dotfiles.programs.neovim.enable {
    programs.nvf = {
      enable = true;
      # EDITOR, so `git commit` and every agent that edits $EDITOR land here.
      defaultEditor = true;
      # One nvf configuration, two consumers: package.nix imports the same files
      # for `nix run .#neovim`.
      settings.imports = [
        ./nvf.nix
        (import ./plugins.nix { inherit pkgs inputs; })
        (import ./runtime-layer.nix { inherit runtime; })
      ];
    };
    home.sessionVariables = {
      VISUAL = "nvim";
      GIT_EDITOR = "nvim";
    };
  };
}
