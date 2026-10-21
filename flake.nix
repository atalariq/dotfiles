{
  description = "Portable native dotfiles and explicit machine capabilities";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "git+https://github.com/nix-community/home-manager?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mangowm = {
      url = "github:mangowm/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs@{ self, nixpkgs, home-manager, ... }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
      eachSystem = nixpkgs.lib.genAttrs systems;
      hostDir = ./hosts/thinkpad-nixos;
      host = builtins.fromJSON (builtins.readFile
        (if builtins.pathExists (hostDir + "/host.local.json")
         then hostDir + "/host.local.json" else hostDir + "/host.json"));
    in {
      homeManagerModules.default = import ./nix/home.nix;
      lib.mkHome = args: home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { system = args.system; };
        modules = [ ./nix/home.nix {
          home.username = args.username;
          home.homeDirectory = args.homeDirectory;
          home.stateVersion = args.homeStateVersion or "26.05";
          dotfiles = {
            checkout = args.checkout;
            configHome = args.configHome or "${args.homeDirectory}/.config";
            include = args.include or [];
            exclude = args.exclude or [];
          };
        } ];
      };
      nixosConfigurations.thinkpad-nixos = nixpkgs.lib.nixosSystem {
        system = host.system;
        modules = [
          ./hosts/thinkpad-nixos/configuration.nix
          ./hosts/thinkpad-nixos/desktop.nix
          ./hosts/thinkpad-nixos/shell.nix
          ./hosts/thinkpad-nixos/workstation.nix
          inputs.mangowm.nixosModules.mango
          inputs.noctalia.nixosModules.default
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${host.username} = {
              imports = [ ./nix/home.nix ];
              home.username = host.username;
              home.homeDirectory = host.homeDirectory;
              home.stateVersion = host.homeStateVersion;
              dotfiles = {
                checkout = host.checkout;
                include = host.include;
                exclude = host.exclude;
              };
            };
          }
        ];
      };
      devShells = eachSystem (system: import ./devshells {
        pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
      });
      formatter = eachSystem (system: nixpkgs.legacyPackages.${system}.nixfmt);
    };
}
