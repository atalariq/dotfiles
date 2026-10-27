# Lua: config/lua/plugins/treesitter.lua (FileType attach, indentation, queries),
#      config/after/ftplugin/{go,lua,html,cpp,markdown,typescript,typst}.lua
#      (per-filetype options), config/after/queries/{bash,toml}/injections.scm.
#
# Parser builds and language runtimes are build time only: the Lua side checks
# `vim.treesitter.language.add` before attaching, so a missing parser degrades to
# the built-in syntax file instead of erroring.
{ pkgs, ... }:
{
  vim = {
    startPlugins = [
      # Parsers are compiled here; treesitter.lua only attaches installed ones.
      (pkgs.vimPlugins.nvim-treesitter.withPlugins (
        p: with p; [
          bash
          diff
          ini
          lua
          luadoc
          markdown
          markdown_inline
          query
          vim
          vimdoc
          nix
          fish
          json
          yaml
          toml
          html
          css
          javascript
          typescript
          tsx
          php
          python
          go
          rust
          c
          cpp
          typst
          java
          kotlin
          sql
        ]
      ))
    ];
    extraPackages = with pkgs; [
      # Parser compilation and the ccache launcher used by ftplugin/cpp.lua.
      gcc
      tree-sitter
      # JS/TS runtimes behind vtsls, prettier and the language servers.
      nodejs_24
      bun
      # Go toolchain: go.nvim and gopls both expect `go` on PATH.
      go
      # Typst toolchain used by ftplugin/typst.lua (tinymist + websocat preview).
      typst
      tinymist
      typstyle
      websocat
    ];
  };
}
