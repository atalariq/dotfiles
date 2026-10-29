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
    llm-agents.url = "github:numtide/llm-agents.nix";

    # Not packaged in nixpkgs; built as vim plugins in the nvf module. mdkite
    # 2.x requires kitehost >= 2.0, so both are pinned together.
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
