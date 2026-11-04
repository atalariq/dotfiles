{ inputs, ... }:
{
  perSystem =
    { system, ... }:
    let
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      editor = import ../modules/nvf/package.nix { inherit inputs pkgs; };
    in
    {
      packages = {
        neovim = editor;
        default = editor;
        # Pinned CLI for the bootstrap recipe before the first activation.
        home-manager = inputs.home-manager.packages.${system}.home-manager;
        # Fresh-install tooling; the Justfile recipes run these from the flake.
        inherit (pkgs) disko nixos-anywhere;
      }
      // pkgs.lib.optionalAttrs (system == "x86_64-linux") {
        # Keep the CLI from the same flake input as colmenaHive.
        colmena = inputs.colmena.packages.${system}.default;
      };

      formatter = pkgs.nixfmt;

      devShells.default = pkgs.mkShell {
        packages =
          (with pkgs; [
            # Interactive bash so a nested `bash` keeps readline: prompt
            # escapes, history and programmable completion work inside the
            # devshell instead of falling back to stdenv's non-interactive one.
            bashInteractive
            git
            just
            # nh backs every Justfile build/activation/gc recipe; without it a
            # fresh clone cannot run them before the first activation.
            nh
            sops
            age
            nix-tree
            deadnix
            statix
            nixfmt
            nixd
          ])
          ++ pkgs.lib.optionals (system == "x86_64-linux") [
            inputs.colmena.packages.${system}.default
          ];
      };
    };
}
