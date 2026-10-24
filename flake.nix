{
  description = "Atalariq's NixOS and Home Manager configuration";

  inputs = {
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    look = {
      url = "github:kunkka19xx/look";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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

  # Per-platform build products are separate from named machine configurations.
  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      perSystem =
        { system, ... }:
        let
          pkgs = import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          editor = import ./packages/neovim { inherit inputs pkgs; };
        in
        {
          packages = {
            neovim = editor;
            default = editor;
            home-manager = inputs.home-manager.packages.${system}.home-manager;
            pencil-dev = pkgs.callPackage ./packages/pencil-dev.nix { };
          }
          // pkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
            concat = pkgs.callPackage ./packages/concat.nix { };
          };
          formatter = pkgs.nixfmt;
          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              nixfmt
              shellcheck
              shfmt
              fish
              jq
              git
              direnv
              nix-direnv
              just
              nh
            ];
          };
          checks = import ./tests { inherit inputs pkgs editor; };
        };
      flake = (import ./lib/hosts.nix { inherit inputs; }) // {
        nixosModules.default = import ./modules/nixos;
        darwinModules.default = import ./modules/darwin;
        homeManagerModules.default = import ./modules/home-manager;
        templates = import ./devshell;
        lib.hostRegistry = import ./hosts;
      };
    };
}
