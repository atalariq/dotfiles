# NixOS

The public module is intentionally small: Nix settings, fish/bash, nix-ld,
OpenSSH, firewall, and GC. Server services and secrets belong to the private
inventory repository.

## Use it as a flake input

```nix
{
  inputs.dotfiles.url = "github:atalariq/dotfiles";
  inputs.dotfiles.inputs.nixpkgs.follows = "nixpkgs";
  inputs.home-manager.follows = "dotfiles/home-manager";

  outputs = { self, nixpkgs, dotfiles, home-manager, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        dotfiles.nixosModules.default
        home-manager.nixosModules.home-manager
        {
          dotfiles.system.base.enable = true;
          networking.hostName = "caladan";
          # ... your users, disks, bootloader
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.atalariq = {
            imports = [ dotfiles.homeManagerModules.default ];
            dotfiles.identity.username = "atalariq";
            dotfiles.identity.device = "caladan";
          };
        }
      ];
    };
  };
}
```

`hosts/example-nixos` is a complete, bootable example with placeholder disks;
change the UUIDs before using it for real.

## What the module does not do

- It does not create secrets or enable sops-nix.
- It does not configure disks, impermanence, Secure Boot, or a desktop.
- It does not set a username or timezone; the host owns those.
