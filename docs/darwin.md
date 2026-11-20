# macOS

## Standalone Home Manager

```sh
home-manager switch --flake .#atalariq@aarch64-darwin
```

This is enough for the terminal workflow. Home Manager does not install GUI
applications; use Homebrew separately if you want them.

## nix-darwin

`hosts/example-darwin` is a minimal nix-darwin host using the same Home Manager
profile. It sets `networking.hostName = "ix"`, Touch ID for sudo, and a few
Finder/Dock defaults. It does **not** enable Homebrew; add it only on a Mac you
own or administer.

```nix
darwinConfigurations.ix = nix-darwin.lib.darwinSystem {
  system = "aarch64-darwin";
  specialArgs = { inherit inputs; };
  modules = [
    dotfiles.darwinModules.default
    home-manager.darwinModules.home-manager
    ./hosts/example-darwin
    {
      home-manager.users.atalariq = {
        imports = [ dotfiles.homeManagerModules.default ];
      };
    }
  ];
};
```

Change `system.primaryUser` and `users.users.<name>.home` together; Home Manager
on Darwin requires an absolute home directory.
