{ inputs }:
let
  lib = inputs.nixpkgs.lib;
  registry = import ../hosts;
  pkgsFor =
    system:
    import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  argsFor =
    system:
    let
      pkgs = pkgsFor system;
    in
    {
      inherit inputs;
      neovimPackage = import ../packages/neovim.nix { inherit inputs pkgs; };
    };
  homeFor = host: { ... }: {
    imports = [ ../modules/home-manager ] ++ (host.profiles or [ ]);
    home = {
      inherit (host) username homeDirectory;
      stateVersion = "26.05";
    };
    xdg.enable = true;
    programs.home-manager.enable = true;
    targets.genericLinux.enable = host.genericLinux or false;
  };
  hmIntegration = host: {
    home-manager = {
      useGlobalPkgs = false;
      useUserPackages = true;
      sharedModules = [ { nixpkgs.config.allowUnfree = true; } ];
      extraSpecialArgs = argsFor host.system;
      users.${host.username} = if host ? home then import host.home else homeFor host;
    };
  };
in
{
  nixosConfigurations =
    lib.mapAttrs
      (
        name: host:
        lib.nixosSystem {
          system = host.system;
          specialArgs = { inherit inputs; };
          modules = [
            inputs.home-manager.nixosModules.home-manager
            (hmIntegration host)
          ]
          ++ (
            if host.kind == "wsl" then
              [
                inputs.nixos-wsl.nixosModules.default
                ({ pkgs, ... }: {
                  wsl.enable = true;
                  wsl.defaultUser = host.username;
                  networking.hostName = name;
                  nixpkgs.config.allowUnfree = true;
                  nix.settings.experimental-features = [
                    "nix-command"
                    "flakes"
                  ];
                  users.users.${host.username}.shell = pkgs.bash;
                  system.stateVersion = "26.05";
                })
              ]
            else
              [ host.module ]
          );
        }
      )
      (
        lib.filterAttrs (
          _: h:
          builtins.elem h.kind [
            "nixos"
            "wsl"
          ]
        ) registry
      );
  darwinConfigurations = lib.mapAttrs (
    _: host:
    inputs.nix-darwin.lib.darwinSystem {
      system = host.system;
      specialArgs = { inherit inputs; };
      modules = [
        host.module
        inputs.home-manager.darwinModules.home-manager
        (hmIntegration host)
        { nixpkgs.config.allowUnfree = true; }
      ];
    }
  ) (lib.filterAttrs (_: h: h.kind == "darwin") registry);
  homeConfigurations = lib.mapAttrs (
    _: host:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = pkgsFor host.system;
      extraSpecialArgs = argsFor host.system;
      modules = [ (homeFor host) ];
    }
  ) (lib.filterAttrs (_: h: h.kind == "home") registry);
}
