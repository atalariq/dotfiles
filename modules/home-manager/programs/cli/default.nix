{
  config,
  lib,
  pkgs,
  ...
}:
let
  packages = import ../../../packages/cli.nix { inherit pkgs lib; };
in
{
  imports = import ../_import-category.nix {
    inherit lib;
    dir = ./.;
  };

  options.dotfiles.programs.cli.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "the shared CLI configuration: fd, ripgrep, fzf, bat and zoxide plus the common package floor";
  };

  # The shared package floor lives in modules/packages/cli.nix. This module owns
  # the Home Manager settings for the tools that need configuration; host-only
  # packages stay in that host's apps.nix. The per-package modules in this
  # directory stay independent of this switch.
  config = lib.mkIf config.dotfiles.programs.cli.enable {
    programs.fd = {
      enable = true;
      ignores = [
        ".git/"
        "node_modules/"
        "dist/"
        "build/"
        "target/"
        "coverage/"
        ".next/"
        ".expo/"
        ".gradle/"
        ".idea/"
        ".vscode/"
      ];
    };

    programs.ripgrep = {
      enable = true;
      arguments = [
        "--hidden"
        "--glob=!.git/*"
        "--glob=!node_modules/*"
        "--glob=!dist/*"
        "--glob=!build/*"
        "--glob=!target/*"
        "--glob=!coverage/*"
        "--smart-case"
        "--line-number"
        "--column"
      ];
    };

    programs.fzf = {
      enable = true;
      enableFishIntegration = false; # Television owns Ctrl-T, Atuin owns Ctrl-R.
      enableBashIntegration = false;
      enableZshIntegration = false;
      defaultOptions = [
        "--height=40%"
        "--layout=reverse"
        "--border"
      ];
      defaultCommand = "fd --type f --hidden --follow --exclude .git";
    };

    programs.bat.enable = true;
    programs.zoxide.enable = true;

    home.packages = packages;
  };
}
