{
  inputs,
  pkgs,
  runtime ? ./config,
  configSource ? null,
  liveRuntime ? false,
}:
let
  # nvf owns the reproducible package, while native Lua preserves behaviour.
  # The same derivation is installed by HM and exposed through nix run.
  custom =
    name:
    pkgs.vimUtils.buildVimPlugin {
      pname = name;
      version = inputs.${name}.shortRev or "locked";
      src = inputs.${name};
    };
  configured = inputs.nvf.lib.neovimConfiguration {
    inherit pkgs;
    modules = [
      ({ lib, ... }: {
        vim = {
          viAlias = false;
          vimAlias = false; # Vim is a separate server editor, not an nvim alias.
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
              (nvim-treesitter.withPlugins (
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
            ])
            ++ map custom [
              "nvim-emmet"
              "pathfinder-nvim"
              "kitehost-nvim"
              "mdkite-nvim"
            ];
          extraPackages =
            with pkgs;
            [
              basedpyright
              ruff
              python3
              python3Packages.debugpy
              clang-tools
              lldb
              git
              ripgrep
              fd
              fzf
              curl
              gzip
              gcc
              tree-sitter
              nixd
              nixfmt
              lua-language-server
              stylua
              selene
              bash-language-server
              shellcheck
              shfmt
              marksman
              rumdl
              yaml-language-server
              yamlfmt
              yamllint
              tombi
              nodejs_24
              bun
              intelephense
              vtsls
              vscode-langservers-extracted
              tailwindcss-language-server
              emmet-language-server
              oxfmt
              prettier
              oxlint
              gopls
              go
              gofumpt
              gotools
              delve
              rust-analyzer
              rustfmt
              typst
              tinymist
              typstyle
              websocat
              jdt-language-server
              jdk17
            ]
            ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [ pkgs.wl-clipboard ];
          luaConfigRC.dotfiles = lib.nvim.dag.entryAfter [ "extraPluginConfigs" ] ''
            vim.g.dotfiles_config_dir = "${runtime}"
            vim.g.dotfiles_source_dir = ${if configSource == null then "nil" else builtins.toJSON configSource}
            vim.g.dotfiles_live_runtime = ${builtins.toJSON liveRuntime}
            vim.g.dotfiles_vale_config = "${./vale.ini}"
            vim.opt.runtimepath:prepend("${runtime}")
            vim.opt.runtimepath:append("${runtime}/after")
            dofile("${runtime}/init.lua")
          '';
        };
      })
    ];
  };
in
configured.neovim
