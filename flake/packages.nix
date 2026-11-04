{ inputs, ... }:
{
  perSystem =
    { system, ... }:
    let
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      # Portable default: no LSP/formatter/linter toolchains, no Nerd Font
      # requirement. Works on any host that only has Nix.
      editor = import ../modules/nvf/package.nix {
        inherit inputs pkgs;
        profile = "minimal";
        nerdFont = false;
      };
      editorFull = import ../modules/nvf/package.nix {
        inherit inputs pkgs;
        profile = "full";
        nerdFont = true;
      };
    in
    {
      packages = {
        neovim = editor;
        neovim-full = editorFull;
        default = editor;
        # Pinned CLI for the bootstrap recipe before the first activation.
        home-manager = inputs.home-manager.packages.${system}.home-manager;
        # Fresh-install tooling; the Justfile recipes run these from the flake.
        inherit (pkgs) disko nixos-anywhere;
      }
      // pkgs.lib.optionalAttrs (system == "x86_64-linux") {
        # Keep the CLI from the same flake input as the deploy output.
        deploy-rs = inputs.deploy-rs.packages.${system}.default;
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
            inputs.deploy-rs.packages.${system}.default
          ];
      };
    };
}
