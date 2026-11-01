# Thin Home Manager wrapper around the shared nvf kernel in `modules/nvf/`.
#
# Everything editor-behavioural lives there (imported by both this wrapper and
# the standalone `nix run .#neovim` package). This file owns only the
# Home-Manager-specific glue: the opt-in flag, the live runtime path, the
# stylix/wana theme gate, and editor environment variables.
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
  # after/ftplugin, queries and snippets can be edited without a rebuild.
  # Keymaps, options and autocmds are declared in Nix and rebuild normally.
  runtime = dotfilesLib.sourceFor "neovim" ../../../nvf/runtime;
  nvfPlugins = import ../../../nvf/plugins.nix { inherit pkgs; };
in
{
  imports = [ inputs.nvf.homeManagerModules.nvf ];

  options.dotfiles.programs.cli.neovim.enable = lib.mkEnableOption "nvf workstation editor";

  config = lib.mkIf config.dotfiles.programs.cli.neovim.enable {
    programs.nvf = {
      enable = true;
      # EDITOR, so `git commit` and every agent that edits $EDITOR land here.
      defaultEditor = true;
      # One nvf kernel, two consumers: package.nix next to it imports the same
      # files for `nix run .#neovim`.
      settings.imports = [
        (import ../../../nvf/nvf.nix { inherit runtime; })
        nvfPlugins.module
        (import ../../../nvf/runtime-layer.nix { inherit runtime; })
        (import ../../../nvf/langs.nix { stacks = config.dotfiles.programs.development.stacks; })
      ];
      # Theme: Stylix owns the palette, but its nvf target still writes the
      # deprecated lualine.theme option, so nvf's base16 theme is wired below.
      # When Stylix is off (lab/wsl-class hosts) the owner's wana.nvim loads,
      # with habamax as the in-editor fallback.
      settings.vim.startPlugins = lib.optionals (!config.stylix.enable) [
        nvfPlugins.packages.wana
      ];
      settings.vim.luaConfigRC.dotfilesTheme = lib.mkIf (!config.stylix.enable) ''
        vim.g.dotfiles_theme = "wana"
      '';
      # Stylix owns the palette; nvf's own target still writes the deprecated
      # lualine.theme option, so the theme is wired explicitly here.
      settings.vim.theme = lib.mkIf (config.stylix.enable && config.dotfiles.appearance.gui) {
        enable = true;
        name = "base16";
        base16-colors = {
          inherit (config.lib.stylix.colors.withHashtag)
            base00
            base01
            base02
            base03
            base04
            base05
            base06
            base07
            base08
            base09
            base0A
            base0B
            base0C
            base0D
            base0E
            base0F
            ;
        };
      };
      settings.vim.statusline.lualine.setupOpts.options.theme = lib.mkIf (
        config.stylix.enable && config.dotfiles.appearance.gui
      ) "base16";
    };
    home.sessionVariables = {
      VISUAL = "nvim";
      GIT_EDITOR = "nvim";
    };
  };
}
