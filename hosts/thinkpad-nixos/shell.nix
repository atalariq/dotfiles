
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    age
    claude-code
    codex
    delta
    difftastic
    fzf
    jq
    lazygit
    rtk
    sops
    tirith
  ];

  programs.fish.enable = true;
}
