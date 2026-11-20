{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.programs.cli.lazygit;
  cli = config.dotfiles.programs.cli;
  source = import ../../lib/source.nix { inherit config; };
in
{
  options.dotfiles.programs.cli.lazygit = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "lazygit with the shared live configuration";
    };
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.lazygit;
      description = "lazygit package to install.";
    };
  };

  config = lib.mkIf (cli.enable && cfg.enable) {
    programs.lazygit = {
      enable = true;
      inherit (cfg) package;
      # The live file below is the only config. An empty settings set keeps
      # Home Manager from writing a second config and lets Stylix's target
      # stand down without fighting the link.
      settings = lib.mkForce { };
      shellWrapperName = "lg";
      # Shell functions are a whole-directory live link in shell.nix; a
      # generated lg.fish would collide with it. The live config provides lg.
      enableFishIntegration = false;
      enableBashIntegration = true;
      enableZshIntegration = false;
      enableNushellIntegration = false;
    };

    home.file."${config.xdg.configHome}/lazygit/config.yml" = {
      # programs.lazygit disables its generated file when settings is empty;
      # this is the live file that replaces it.
      enable = lib.mkForce true;
      source = lib.mkForce (
        source ./config/lazygit/config.yml "modules/home-manager/programs/cli/config/lazygit/config.yml"
      );
    };
  };
}
