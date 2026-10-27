# Lua: config/lua/plugins/lsp.lua (vim.lsp.config/enable, lazydev, go.nvim),
#      config/lua/plugins/lint.lua (nvim-lint linters), config/lua/plugins/conform.lua
#      (formatters), config/lua/plugins/debug.lua (nvim-dap adapters).
#
# nvf Nix language support below (`vim.languages.nix.*`) mirrors the `nixd`
# entry that lsp.lua configures at runtime; keep both in sync, and keep nixd in
# extraPackages because the Lua tree resolves it from PATH.
#
# Everything here is a build-time binary on the wrapped `nvim`'s PATH. The Lua
# files only reference these executables by name, so a tool that disappears from
# this list disables its feature silently — keep the two in sync.
{ pkgs, ... }:
{
  vim = {
    # nvf owns the Nix server preset; lsp.enable is explicit because the global
    # `vim.lsp.enable` switch stays off and the Lua tree owns the other servers.
    languages.nix = {
      enable = true;
      lsp = {
        enable = true;
        servers = [ "nixd" ];
      };
    };
    extraPackages = with pkgs; [
      # lua/lazydev and Nix tooling for this tree itself.
      lua-language-server
      stylua
      selene
      nixd
      nixfmt
      # Python.
      basedpyright
      ruff
      python3
      python3Packages.debugpy
      # C/C++ and debug adapters.
      clang-tools
      lldb
      # Shell.
      bash-language-server
      shellcheck
      shfmt
      # Markdown.
      marksman
      rumdl
      # YAML/TOML.
      yaml-language-server
      yamlfmt
      yamllint
      tombi
      # PHP.
      intelephense
      # TypeScript/JS and web.
      vtsls
      vscode-langservers-extracted
      tailwindcss-language-server
      emmet-language-server
      oxfmt
      prettier
      oxlint
      # Go.
      gopls
      gofumpt
      gotools
      delve
      # Rust.
      rust-analyzer
      rustfmt
      # Java.
      jdt-language-server
      jdk17
    ];
  };
}
