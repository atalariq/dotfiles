{
  config,
  lib,
  pkgs,
  inputs,
  dotfilesLib,
  ...
}:
let
  # "neovim" is a live app: the runtime tree links back to the checkout, so
  # keymaps and options can be edited without a rebuild while everything build
  # time still comes from a generation.
  runtime = dotfilesLib.sourceFor "neovim" ./runtime;
in
{
  imports = [ inputs.nvf.homeManagerModules.nvf ];

  options.dotfiles.programs.neovim.enable = lib.mkEnableOption "nvf workstation editor";

  config = lib.mkIf config.dotfiles.programs.neovim.enable {
    programs.nvf = {
      enable = true;
      # EDITOR, so `git commit` and every agent that edits $EDITOR land here.
      defaultEditor = true;
      # One nvf configuration, two consumers: package.nix imports the same files
      # for `nix run .#neovim`.
      settings.imports = [
        ./nvf.nix
        (import ./plugins.nix { inherit pkgs inputs; })
        (import ./runtime-layer.nix { inherit runtime; })
        (import ./stacks-langs.nix { stacks = config.dotfiles.dev.stacks; })
      ];
      # Theme: Stylix owns nvf's colors through `stylix.targets.nvf`; only when
      # stylix is off (lab/wsl-class hosts) does the owner's wana.nvim load,
      # with habamax as the in-editor fallback. The `!stylix.enable` gates are
      # what keep the two owners from colliding.
      settings.vim.startPlugins = lib.optionals (!config.stylix.enable) [
        (pkgs.vimUtils.buildVimPlugin {
          pname = "wana";
          version = "0-unstable-2026-10-31";
          src = inputs.wana;
        })
      ];
      settings.vim.luaConfigRC.dotfilesTheme = lib.mkIf (!config.stylix.enable) ''
        vim.g.dotfiles_theme = "wana"
      '';
    };
    home.sessionVariables = {
      VISUAL = "nvim";
      GIT_EDITOR = "nvim";
    };
  };
}
