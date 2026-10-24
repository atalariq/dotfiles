{
  description = "Atalariq's NixOS and Home Manager configuration";

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
    lerd = {
      url = "github:lerd-env/lerd-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvf = {
      url = "github:NotAShelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    llm-agents.url = "github:numtide/llm-agents.nix";
    nvim-emmet = {
      url = "github:olrtg/nvim-emmet/cde4fb2968704aae5c18b7f8a9bc2508767bb78d";
      flake = false;
    };
    pathfinder-nvim = {
      url = "github:HawkinsT/pathfinder.nvim/9c79815dfd31726119b44a71c0654377be01d3c2";
      flake = false;
    };
    kitehost-nvim = {
      url = "github:selimacerbas/kitehost.nvim/4cb5c94a84cc653e0b32e0c9aed95465a36fc94d";
      flake = false;
    };
    mdkite-nvim = {
      url = "github:selimacerbas/mdkite.nvim/dded03dc6cce87364b48260b2ffbace575a6add7";
      flake = false;
    };

  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      editor = import ./packages/neovim { inherit inputs pkgs; };
      host = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/nixos/thinkpad-x13
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inherit inputs;
              neovimPackage = editor;
            };
            home-manager.users.atalariq = import ./hosts/nixos/thinkpad-x13/home.nix;
          }
        ];
      };
    in
    {
      nixosConfigurations = {
        thinkpad-x13 = host;
      };
      homeConfigurations.portable = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit inputs;
          neovimPackage = editor;
        };
        modules = [ ./profiles/portable.nix ];
      };
      nixosModules.default = import ./modules/nixos;
      homeManagerModules.default = import ./modules/home-manager;
      packages.${system} = {
        neovim = editor;
        default = editor;
        home-manager = home-manager.packages.${system}.home-manager;
      };
      formatter.${system} = pkgs.nixfmt;
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          nixfmt
          shellcheck
          shfmt
          fish
          jq
          git
          direnv
          nix-direnv
        ];
      };
      checks.${system} = import ./tests { inherit inputs pkgs editor; };
      templates = import ./devshell;
    };
}
