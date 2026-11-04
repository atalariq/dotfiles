{
  description = "Atalariq's NixOS and Home Manager configuration";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";

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
    # NixOS-only remote deployment. The hive shares host modules with
    # nixosConfigurations; it never replaces local activation recipes.
    colmena = {
      url = "github:nix-community/colmena";
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
    # Secure Boot (UKI signing) + measured boot (systemd-pcrlock). Pinned to a
    # rev; update deliberately and re-verify the enroll flow afterwards.
    lanzaboote = {
      url = "github:nix-community/lanzaboote/4b98333073bdaf9b1b5dd7d87c2dab96883b234e";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix/master";
      inputs.nixpkgs.follows = "nixpkgs";
      # Otherwise the lock keeps two copies of flake-parts.
      inputs.flake-parts.follows = "flake-parts";
    };
    # Fresh-install tooling: disko renders the disk layout (and mounts it for
    # nixos-anywhere), impermanence keeps the server's root volatile.
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "nixpkgs";
      # Only the NixOS module is used; keep one Home Manager pin in the lock.
      inputs.home-manager.follows = "home-manager";
    };
    llm-agents.url = "github:numtide/llm-agents.nix";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      imports = [
        ./flake/packages.nix
        ./flake/hosts.nix
      ];
    };
}
