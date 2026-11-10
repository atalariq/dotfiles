# Host wiring lives here as an explicit list: every machine names its own
# modules and Home Manager user, so a new host is one visible block instead of
# a table that hides per-host differences.
{ inputs, ... }:
let
  lib = inputs.nixpkgs.lib;
  # Unfree is decided where pkgs is created. NixOS entry points share this
  # pre-imported instance so system and Home Manager see one policy.
  pkgsFor =
    system:
    import inputs.nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
        # Zotero 10 still embeds Firefox ESR 140, which nixpkgs marks EOL.
        # Keep the exact pin local to the one consumer; remove when Zotero
        # updates its Gecko version.
        permittedInsecurePackages = [
          "firefox-esr-140-bin-unwrapped-140.17.0esr"
        ];
      };
    };
  mkHome =
    host:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = pkgsFor "x86_64-linux";
      extraSpecialArgs = { inherit inputs; };
      modules = [ host ];
    };
  withHome = username: user: {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = { inherit inputs; };
      backupFileExtension = "backup";
      users.${username} = import user;
    };
  };
  nixosModulesFor = host: user: [
    host
    inputs.brave.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
    (withHome "atalariq" user)
  ];
  mkNixosHost =
    host: user:
    lib.nixosSystem {
      pkgs = pkgsFor "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = nixosModulesFor host user;
    };
  deploy = {
    nodes = {
      # ThinkPad stays local: its SSH server is intentionally disabled.
      homelab-x456urk = {
        hostname = "homelab-x456urk";
        sshUser = "atalariq";
        profiles.system = {
          user = "root";
          path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.homelab-x456urk;
        };
      };
      macpro-m4 = {
        hostname = "macpro-m4";
        sshUser = "atalariq";
        interactiveSudo = true;
        remoteBuild = true;
        profiles.system = {
          user = "root";
          path = inputs.deploy-rs.lib.aarch64-darwin.activate.darwin inputs.self.darwinConfigurations.macpro-m4;
        };
      };
      macmini-lab = {
        # Use an SSH alias or resolvable address; the lab owns the hostname.
        hostname = "macmini-lab";
        sshUser = "praktikan";
        interactiveSudo = true;
        remoteBuild = true;
        profiles.system = {
          user = "root";
          path = inputs.deploy-rs.lib.aarch64-darwin.activate.darwin inputs.self.darwinConfigurations.macmini-lab;
        };
      };
    };
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
        (withHome "atalariq" ../hosts/darwin/macpro-m4/home.nix)
      ];
    };

    # Campus lab Mac mini. GUI apps are Homebrew-owned; Nix supplies only
    # CLI/TUI tooling. The hostname stays under macOS/lab control.
    darwinConfigurations.macmini-lab = inputs.nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = { inherit inputs; };
      modules = [
        ../hosts/darwin/macmini-lab
        inputs.home-manager.darwinModules.home-manager
        {
          nixpkgs.config.allowUnfree = true;
        }
        (withHome "praktikan" ../hosts/darwin/macmini-lab/home.nix)
      ];
    };

    homeConfigurations = {
      linux-lab = mkHome ../hosts/linux/lab;
      wsl-lab = mkHome ../hosts/wsl/lab;
    };

    # SSH deployment for the homelab and Macs. The local ThinkPad keeps the
    # nh/nixos-rebuild activation recipes in the Justfile.
    inherit deploy;
    # deployChecks builds each profile's activation path. Keep the Linux check
    # limited to the Linux node so a ThinkPad flake check does not try to build
    # aarch64-darwin's Homebrew activation on x86_64-linux.
    checks = {
      x86_64-linux = inputs.deploy-rs.lib.x86_64-linux.deployChecks {
        nodes = {
          homelab-x456urk = deploy.nodes.homelab-x456urk;
        };
      };
      aarch64-darwin = inputs.deploy-rs.lib.aarch64-darwin.deployChecks {
        nodes = {
          macpro-m4 = deploy.nodes.macpro-m4;
          macmini-lab = deploy.nodes.macmini-lab;
        };
      };
    };
  };
}
