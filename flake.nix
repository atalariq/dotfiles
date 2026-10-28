{
  description = "Atalariq's NixOS and Home Manager configuration";

  inputs = {
    # One nixpkgs for every host. Unstable is the default so desktop packages and
    # the system closure share a single evaluation graph.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Keep the cache-provided pins: following nixpkgs would miss their Cachix
    # closures.
    noctalia.url = "github:noctalia-dev/noctalia/cachix";
    umbriel.url = "github:noctalia-dev/umbriel/cachix";
    nvf = {
      url = "github:NotAShelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    llm-agents.url = "github:numtide/llm-agents.nix";
  };

  # Portable fallback for standalone Home Manager hosts, where no system module
  # owns nix.conf. NixOS and nix-darwin declare the authoritative settings in
  # modules/nix-cache.nix; nixConfig cannot import, so keep both lists in sync.
  nixConfig = {
    extra-substituters = [
      "https://noctalia.cachix.org"
      "https://umbriel.cachix.org"
      "https://cache.numtide.com"
    ];
    extra-trusted-public-keys = [
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      "umbriel.cachix.org-1:JfNq/2ygS6D6z4Z2dVSZrZlDPQTKtexB6GAVLD98nw="
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
    ];
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
      mkPkgs =
        system:
        import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      perSystem = lib.genAttrs systems (
        system:
        let
          pkgs = mkPkgs system;
          editor = import ./modules/home-manager/programs/neovim/package.nix { inherit inputs pkgs; };
        in
        {
          packages = {
            neovim = editor;
            default = editor;
            home-manager = inputs.home-manager.packages.${system}.home-manager;
          };
          formatter = pkgs.nixfmt;
          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              # Interactive bash so a nested `bash` keeps readline: prompt
              # escapes, history and programmable completion work inside the
              # devshell instead of falling back to stdenv's non-interactive one.
              bashInteractive
              git
              just
              sops
              age
              nix-tree
              deadnix
              statix
              nixfmt
              nixd
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
          pkgs = mkPkgs "x86_64-linux";
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
      homeModules.default = import ./modules/home-manager;
      templates = import ./devshell;
    };
}
