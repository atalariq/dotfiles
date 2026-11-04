# Host wiring lives here as an explicit list: every machine names its own
# modules and Home Manager user, so a new host is one visible block instead of
# a table that hides per-host differences.
{ inputs, ... }:
let
  lib = inputs.nixpkgs.lib;
  # Unfree is decided where pkgs is created. Colmena's meta.nixpkgs sets
  # nixpkgs.pkgs, and NixOS rejects a non-empty nixpkgs.config alongside it,
  # so both entry points share this pre-imported instance.
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
  nixosModulesFor = host: user: [
    host
    inputs.home-manager.nixosModules.home-manager
    (withHome user)
  ];
  mkNixosHost =
    host: user:
    lib.nixosSystem {
      pkgs = pkgsFor "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = nixosModulesFor host user;
    };
in
{
  flake = {
    nixosConfigurations.thinkpad-x13 = mkNixosHost ../hosts/nixos/thinkpad-x13 ../hosts/nixos/thinkpad-x13/home.nix;

    # Headless homelab server, installed fresh with disko + nixos-anywhere.
    # No desktop modules: the host owns a volatile root and a persistence list.
    nixosConfigurations.homelab-x456urk = mkNixosHost ../hosts/nixos/homelab-x456urk ../hosts/nixos/homelab-x456urk/home.nix;

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

    # NixOS-only deployment. Darwin and standalone Home Manager keep their
    # native recipes. Nodes reuse the exact module lists above so the hive
    # cannot drift from nixosConfigurations.
    colmenaHive = inputs.colmena.lib.makeHive {
      meta = {
        nixpkgs = pkgsFor "x86_64-linux";
        specialArgs = { inherit inputs; };
      };
      thinkpad-x13 = {
        imports = nixosModulesFor ../hosts/nixos/thinkpad-x13 ../hosts/nixos/thinkpad-x13/home.nix;
        deployment = {
          # Local activation only: apply-local with sudo, not SSH.
          targetHost = null;
          allowLocalDeployment = true;
          tags = [ "desktop" ];
        };
      };
      homelab-x456urk = {
        imports = nixosModulesFor ../hosts/nixos/homelab-x456urk ../hosts/nixos/homelab-x456urk/home.nix;
        deployment = {
          targetHost = "homelab-x456urk";
          targetUser = "atalariq";
          tags = [ "server" ];
        };
      };
    };
  };
}
