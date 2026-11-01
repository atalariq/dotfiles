{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.programs.cli;
in
{
  options.dotfiles.programs.cli.git.enable = lib.mkEnableOption "git, delta and difftastic" // {
    default = true;
  };

  config = lib.mkIf (cfg.enable && cfg.git.enable) {
    programs.git = {
      enable = lib.mkDefault true;
      lfs.enable = lib.mkIf config.programs.git.enable true;
      settings = lib.mkIf config.programs.git.enable {
        "user" = {
          name = lib.mkDefault "Atalariq Barra Hadinugraha";
          email = lib.mkDefault "atalariq.dev@outlook.com";
          username = lib.mkDefault "atalariq";
        };
        "core" = {
          "editor" = "vim";
          "autocrlf" = "input";
        };
        "init" = {
          "defaultbranch" = "main";
        };
        "http" = {
          "postbuffer" = "524288000";
        };
        "pull" = {
          "rebase" = "false";
        };
        "fetch" = {
          "prune" = "true";
        };
        "rerere" = {
          "enabled" = "true";
        };
        "rebase" = {
          "autostash" = "true";
        };
        "push" = {
          "autosetupremote" = "true";
        };
        "diff" = {
          "algorithm" = "histogram";
        };
        "merge" = {
          "conflictstyle" = "zdiff3";
        };
        "gpg" = {
          "format" = "ssh";
        };
        "include" = {
          "path" = "~/.gitconfig.local";
        };
        "alias" = {
          "dft" = "-c diff.external=difft diff";
        };
      };
      ignores = lib.mkIf config.programs.git.enable (
        lib.splitString "\n" (builtins.readFile ./config/git/gitignore_global)
      );
    };

    programs.delta = {
      enable = lib.mkDefault true;
      enableGitIntegration = lib.mkDefault true;
    };

    home.packages = lib.mkIf config.programs.git.enable [
      pkgs.difftastic
    ];
  };
}
