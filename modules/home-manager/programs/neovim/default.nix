{
  config,
  lib,
  pkgs,
  inputs,
  dotfilesLib,
  ...
}:
let
  liveRuntime =
    config.dotfiles.deployment.mode == "live"
    || builtins.elem "neovim" config.dotfiles.deployment.liveApps;
  configSource = "${config.dotfiles.deployment.checkout}/modules/home-manager/programs/neovim/config";
  # Only native files can use live mode. Plugin/tool changes always rebuild.
  editor = import ./package.nix (
    {
      inherit
        inputs
        pkgs
        configSource
        liveRuntime
        ;
    }
    // lib.optionalAttrs liveRuntime {
      runtime = dotfilesLib.sourceFor "neovim" ./config;
    }
  );
in
{
  options.dotfiles.programs.neovim.enable = lib.mkEnableOption "nvf workstation editor";
  config = lib.mkIf config.dotfiles.programs.neovim.enable {
    home.packages = [ editor ];
    home.sessionVariables = {
      DOTFILES_NVIM_SOURCE = configSource;
      EDITOR = "nvim";
      VISUAL = "nvim";
      GIT_EDITOR = "nvim";
    };
    xdg.configFile."vale/.vale.ini".source = dotfilesLib.source ./vale.ini;
  };
}
