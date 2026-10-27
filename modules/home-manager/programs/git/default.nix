{
  config,
  lib,
  pkgs,
  dotfilesLib,
  ...
}:
{
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
      lib.splitString "\n" (builtins.readFile ./config/gitignore_global)
    );
  };

  programs.delta = {
    enable = lib.mkDefault true;
    enableGitIntegration = lib.mkDefault true;
  };

  home.packages = lib.mkIf config.programs.git.enable [
    pkgs.difftastic
    pkgs.lazygit
  ];

  xdg.configFile."lazygit" = lib.mkIf config.programs.git.enable {
    source = dotfilesLib.themedDirectory ./config/lazygit;
  };
}
