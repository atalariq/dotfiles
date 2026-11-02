# Host wiring lives here as an explicit list: every machine names its own
# modules and Home Manager user, so a new host is one visible block instead of
# a table that hides per-host differences.
{ inputs, ... }:
let
  lib = inputs.nixpkgs.lib;
  # Standalone Home Manager has no nixpkgs config of its own, so unfree has to
  # be decided here.
  pkgsFor =
    system:
    import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  mkHome =
    host:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = pkgsFor "x86_64-linux";
      extraSpecialArgs = { inherit inputs; };
      modules = [ host ];
    };
  withHome = user: {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = { inherit inputs; };
      users.atalariq = import user;
    };
  };
in
{
  flake = {
    nixosConfigurations.thinkpad-x13 = lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ../hosts/nixos/thinkpad-x13
        inputs.home-manager.nixosModules.home-manager
        (withHome ../hosts/nixos/thinkpad-x13/home.nix)
      ];
    };

    # Headless homelab server, installed fresh with disko + nixos-anywhere.
    # No desktop modules: the host owns a volatile root and a persistence list.
    nixosConfigurations.homelab-x456urk = lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ../hosts/nixos/homelab-x456urk
        inputs.home-manager.nixosModules.home-manager
        (withHome ../hosts/nixos/homelab-x456urk/home.nix)
      ];
    };

    darwinConfigurations.macpro-m4 = inputs.nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = { inherit inputs; };
      modules = [
        ../hosts/darwin/macpro-m4
        inputs.home-manager.darwinModules.home-manager
        {
          nixpkgs.config.allowUnfree = true;
        }
        (withHome ../hosts/darwin/macpro-m4/home.nix)
      ];
    };

    homeConfigurations = {
      linux-lab = mkHome ../hosts/linux/lab;
      wsl-lab = mkHome ../hosts/wsl/lab;
    };
  };
}
