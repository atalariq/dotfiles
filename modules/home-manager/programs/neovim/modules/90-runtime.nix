# Lua: config/init.lua (reads the dotfiles_* globals and is dofile'd last),
#      config/lua/plugins/fzf.lua (:DotfilesConfig uses the source dir/live flag),
#      config/lua/plugins/lint.lua and conform.lua (`dotfiles_vale_config`,
#      `dotfiles_config_dir/selene.toml`).
#
# This module is the only build-time bridge to the navigation arguments:
# `runtime` (config tree, either the store copy or the live checkout),
# `configSource` (checkout path for :DotfilesConfig) and `liveRuntime`.
{
  runtime,
  configSource ? null,
  liveRuntime ? false,
}:
{ lib, ... }:
{
  vim = {
    # Runs after nvf's own plugin config and before anything the Lua tree does.
    luaConfigRC.dotfiles = lib.nvim.dag.entryAfter [ "extraPluginConfigs" ] ''
      vim.g.dotfiles_config_dir = "${runtime}"
      vim.g.dotfiles_source_dir = ${if configSource == null then "nil" else builtins.toJSON configSource}
      vim.g.dotfiles_live_runtime = ${builtins.toJSON liveRuntime}
      vim.g.dotfiles_vale_config = "${../vale.ini}"
      vim.opt.runtimepath:prepend("${runtime}")
      vim.opt.runtimepath:append("${runtime}/after")
      dofile("${runtime}/init.lua")
    '';
  };
}
