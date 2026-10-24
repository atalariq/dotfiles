{ pkgs, ... }:
{
  programs.kitty.enable = true;
  dotfiles.appearance = {
    enable = true;
    gui = true;
  };
  home.packages = with pkgs; [
    localsend
    scrcpy
    lazysql
  ];
}
