# Lua: config/init.lua (leader keys, load order), config/lua/core/options.lua
#      (runtime options), config/lua/core/keymaps.lua, config/lua/core/autocmds.lua,
#      config/lua/core/utils.lua (shared helpers for the plugin modules).
#
# Precedence: where to change what
# --------------------------------
# nvf evaluates this directory at build time and bakes the result into the
# wrapped `nvim` derivation. Editor state can come from three layers, applied in
# this order:
#
# 1. nvf `vim.*` options (this directory), e.g. the aliases below and nvf's own
#    defaults: `vim.g.mapleader = " "`, `vim.g.maplocalleader = ","`,
#    `vim.g.editorconfig = true`.
# 2. nvf `vim.luaConfigRC.dotfiles` (90-runtime.nix): `dotfiles_*` globals plus
#    the runtimepath prepend/append, evaluated after nvf's generated config.
# 3. The native Lua tree, sourced last by `dofile("${runtime}/init.lua")`.
#
# Layer 3 wins for anything it touches. Concretely:
#
# - Keymaps, `vim.opt.*`, autocmds and UI state stay in Lua. `options.lua`
#   sets `maplocalleader = "\\"`, which overrides nvf's build-time default `","`;
#   do not move those options here, they would be shadowed at startup anyway.
# - Build-time only values belong in 90-runtime.nix: the resolved runtime path,
#   the checkout path, the live-mode flag and the packaged `vale.ini`.
# - Plugin binaries and start plugins are build-time only (10/20/30/40-*.nix).
#   The Lua tree cannot install or update them; it can only configure them.
# - The aliases below are the only editor behaviour this file sets. They create
#   the `vi`/`vim` wrapper binaries, not options. Keep them false: Vim is a
#   separate server editor here, so `vim` must not resolve to this `nvim`.
{ pkgs, ... }:
{
  vim = {
    viAlias = false;
    vimAlias = false;
    # Shared CLI dependencies of the Lua tree: fzf-lua and vim-fugitive assume
    # git/ripgrep/fd/fzf exist, and image/link helpers need curl/gzip.
    extraPackages = with pkgs; [
      git
      ripgrep
      fd
      fzf
      curl
      gzip
    ];
  };
}
