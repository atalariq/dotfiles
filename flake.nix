{
  description = "Atalariq's NixOS and Home Manager configuration";

  inputs = {
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
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

  outputs =
    inputs:
    let
      lib = inputs.nixpkgs.lib;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      perSystem = lib.genAttrs systems (
        system:
        let
          pkgs = import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          editor = import ./modules/home-manager/programs/neovim/package.nix { inherit inputs pkgs; };
        in
        {
          packages = {
            neovim = editor;
            default = editor;
            home-manager = inputs.home-manager.packages.${system}.home-manager;
            pencil-dev = pkgs.callPackage ./modules/home-manager/programs/pen/package.nix { };
          }
          // pkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
            mango = import ./modules/home-manager/desktop/mango/package.nix { inherit inputs pkgs; };
            pluto-shelf = pkgs.callPackage ./modules/home-manager/desktop/pluto/package.nix { };
            concat = pkgs.callPackage ./modules/home-manager/programs/concat/package.nix { };
          };
          formatter = pkgs.nixfmt;
          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              nixfmt
              git
              just
              sops
              age
            ];
          };
          checks.neovim-startup = pkgs.runCommand "neovim-startup" { nativeBuildInputs = [ editor ]; } ''
            export HOME="$TMPDIR/home"
            mkdir -p "$HOME"
            nvim --headless -i NONE -n '+lua local ok, err = pcall(require, "conform"); if not ok or vim.v.errmsg ~= "" then io.stderr:write(tostring(err) .. vim.v.errmsg); vim.cmd("cquit 1") end; assert(package.loaded["plugins.cmp"]); assert(package.loaded["plugins.debug"]); assert(vim.fn.exists(":PackInstall") == 0)' +qa
            touch "$out"
          '';
        }
      );
      mkHome =
        host:
        inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = import inputs.nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
          extraSpecialArgs = { inherit inputs; };
          modules = [ host ];
        };
    in
    {
      packages = lib.mapAttrs (_: value: value.packages) perSystem;
      formatter = lib.mapAttrs (_: value: value.formatter) perSystem;
      devShells = lib.mapAttrs (_: value: value.devShells) perSystem;
      checks = lib.mapAttrs (_: value: value.checks) perSystem;
      nixosConfigurations.thinkpad-x13 = lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/nixos/thinkpad-x13
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit inputs; };
              users.atalariq = import ./hosts/nixos/thinkpad-x13/home.nix;
            };
          }
        ];
      };
      darwinConfigurations.macpro-m4 = inputs.nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/darwin/macpro-m4
          inputs.home-manager.darwinModules.home-manager
          {
            nixpkgs.config.allowUnfree = true;
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit inputs; };
              users.atalariq = import ./hosts/darwin/macpro-m4/home.nix;
            };
          }
        ];
      };
      homeConfigurations = {
        linux-lab = mkHome ./hosts/linux/lab;
        wsl-lab = mkHome ./hosts/wsl/lab;
      };
      nixosModules.default = import ./modules/nixos;
      darwinModules.default = import ./modules/darwin;
      homeManagerModules.default = import ./modules/home-manager;
      templates = import ./devshell;
    };
}
