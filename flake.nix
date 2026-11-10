{
  description = "Atalariq's NixOS and Home Manager configuration";

  # Cross-platform caches only. NixOS and nix-darwin also regenerate
  # /etc/nix/nix.conf from modules/nix-cache.nix (which adds the Linux-only
  # Noctalia/Umbriel caches). This block closes the bootstrap gap: a fresh host
  # can substitute before the first activation has applied that module.
  #
  # Nix honours flake nixConfig for trusted users; other hosts must pass
  # --accept-flake-config (the Justfile bootstrap/apply recipes do).
  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://cache.numtide.com"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+rkXd32PYzeVMqw="
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
    ];
  };

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";

    # One nixpkgs for every host. Brave is temporarily supplied by the
    # community flake below because nixos-unstable still predates the
    # 2026-11-07 re-add of brave/brave-origin.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    brave = {
      url = "git+https://codeberg.org/buckley310/brave-browser-nix?ref=main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # SSH deployment for NixOS and nix-darwin. The flake's deploy output
    # reuses the same host configurations; local ThinkPad activation stays
    # local because its SSH server is intentionally disabled.
    deploy-rs = {
      url = "github:serokell/deploy-rs";
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
    # Experimental Navidrome clients for the ThinkPad. Ratune has a native
    # Home Manager module; NaviBeat is a community AppImage wrapper (unfree).
    ratune = {
      url = "github:acmagn/ratune";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    navibeat = {
      url = "github:dmnc98/navibeat-flake";
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
