{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.git = lib.mkIf config.programs.git.enable {
    lfs.enable = true;
    settings = {
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
    ignores = lib.splitString "\n" (builtins.readFile ./config/gitignore_global);
  };
  home.packages = lib.mkIf config.programs.git.enable [ pkgs.difftastic ];
}
