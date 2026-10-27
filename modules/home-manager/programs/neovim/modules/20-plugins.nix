# Lua: config/lua/plugins/init.lua (load order and plugin setup),
#      config/lua/plugins/{fzf,mini,cmp,gitsigns,debug,conform,lint,lsp,treesitter}.lua
#      configure these plugins; the Lua tree never installs them.
#
# This module owns plugin *availability* only: everything below ends up on the
# wrapped `nvim`'s packpath at build time. Treesitter parsers live in
# 40-languages.nix because their parser set is a language concern.
{ custom }:
{ pkgs, ... }:
{
  vim = {
    startPlugins =
      (with pkgs.vimPlugins; [
        blink-cmp
        blink-indent
        blink-lib
        blink-cmp-git
        conform-nvim
        dial-nvim
        friendly-snippets
        fyler-nvim
        fzf-lua
        gitsigns-nvim
        go-nvim
        guess-indent-nvim
        img-clip-nvim
        lazydev-nvim
        nvim-autopairs
        nvim-colorizer-lua
        nvim-dap
        nvim-dap-view
        nvim-lint
        nvim-lspconfig
        nvim-origami
        nvim-ts-autotag
        plenary-nvim
        quicker-nvim
        render-markdown-nvim
        trouble-nvim
        typst-preview-nvim
        vim-fugitive
        mini-ai
        mini-align
        mini-base16
        mini-bracketed
        mini-bufremove
        mini-clue
        mini-cursorword
        mini-extra
        mini-hipatterns
        mini-icons
        mini-input
        mini-jump
        mini-jump2d
        mini-move
        mini-splitjoin
        mini-statusline
        mini-surround
        mini-tabline
      ])
      # Pinned flake inputs that are not in nixpkgs; package.nix builds them
      # with `custom`. Order is preserved from the previous single module.
      ++ map custom [
        "nvim-emmet"
        "pathfinder-nvim"
        "kitehost-nvim"
        "mdkite-nvim"
      ];
  };
}
