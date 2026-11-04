{ pkgs, ... }:
let
  apps = import ./apps.nix { inherit pkgs; };
in
{
  imports = [ ../../../modules/darwin ];
  networking.hostName = "macpro-m4";
  system.primaryUser = "atalariq";
  users.users.atalariq = {
    home = "/Users/atalariq";
    shell = pkgs.fish;
  };
  nixpkgs.hostPlatform = "aarch64-darwin";
  system.stateVersion = 6;
  homebrew = {
    enable = true;
    inherit (apps) casks;
  };
}
