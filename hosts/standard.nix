{ pkgs, ... }:
{
  imports = [
    ../modules/desktop
    ../modules/authentication
    ../modules/lerd
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;
  programs.fish.enable = true;
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  services.openssh.enable = true;
  environment.systemPackages = [ pkgs.bubblewrap ];
}
