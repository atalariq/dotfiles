{
  description = "Reusable terminal-first dotfiles: NixOS, Linux, macOS, and WSL";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvf = {
      url = "github:NotAShelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      nix-darwin,
      ...
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAll = nixpkgs.lib.genAttrs systems;
      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

      # Change these two lines per device. `device` is only a label; it does
      # not change the operating system's hostname.
      username = "atalariq";
      device = "heighliner";

      identity = {
        dotfiles.identity = {
          inherit username device;
        };
      };

      homeProfile = [
        ./home/example.nix
        identity
      ];

      mkHome =
        system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsFor system;
          extraSpecialArgs = { inherit inputs; };
          modules = homeProfile;
        };
    in
    {
      homeManagerModules.default = ./modules/home-manager;
      nixosModules.default = ./modules/nixos;
      darwinModules.default = ./modules/darwin;

      lib.mkHome =
        {
          system,
          username ? "atalariq",
          device ? "heighliner",
          extraModules ? [ ],
        }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsFor system;
          extraSpecialArgs = { inherit inputs; };
          modules = [
            ./home/example.nix
            {
              dotfiles.identity = { inherit username device; };
            }
          ]
          ++ extraModules;
        };
      homeConfigurations = {
        "${username}@x86_64-linux" = mkHome "x86_64-linux";
        "${username}@aarch64-linux" = mkHome "aarch64-linux";
        "${username}@x86_64-darwin" = mkHome "x86_64-darwin";
        "${username}@aarch64-darwin" = mkHome "aarch64-darwin";
      };

      nixosConfigurations.caladan = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/example-nixos
          home-manager.nixosModules.home-manager
          {
            nixpkgs.config.allowUnfree = true;
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.${username} = {
              imports = homeProfile;
            };
          }
        ];
      };

      darwinConfigurations.ix = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/example-darwin
          home-manager.darwinModules.home-manager
          {
            nixpkgs.config.allowUnfree = true;
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.${username} = {
              imports = homeProfile;
            };
          }
        ];
      };

      packages = forAll (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          neovim = import ./modules/nvf/package.nix {
            inherit inputs pkgs;
            profile = "minimal";
            nerdFont = false;
          };
          neovim-full = import ./modules/nvf/package.nix {
            inherit inputs pkgs;
            profile = "full";
            nerdFont = true;
          };
          default = import ./modules/nvf/package.nix {
            inherit inputs pkgs;
            profile = "minimal";
            nerdFont = false;
          };
        }
      );

      formatter = forAll (system: (pkgsFor system).nixfmt);

      devShells = forAll (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              git
              just
              deadnix
              statix
              nixfmt
              gitleaks
            ];
          };
        }
      );

      templates.default = {
        path = ./templates/default;
        description = "A standalone Home Manager profile using these dotfiles";
      };
    };
}
