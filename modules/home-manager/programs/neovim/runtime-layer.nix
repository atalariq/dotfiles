# The only bridge from build time to runtime.
#
# nvf bakes its configuration into the wrapper, so the live tree in `runtime/`
# is added to the runtime path at startup and sourced last: anything there can
# override what nvf declared, without a rebuild.
#
# Curried: the outer argument is ours, the inner one is supplied by nvf's module
# system (Home Manager's settings submodule or neovimConfiguration), which is
# where `lib.nvim` comes from.
{ runtime }:
{ lib, ... }:
{
  vim.luaConfigRC.dotfilesRuntime = lib.nvim.dag.entryAfter [ "extraPluginConfigs" ] ''
    vim.opt.runtimepath:prepend("${runtime}")
    vim.opt.runtimepath:append("${runtime}/after")
    dofile("${runtime}/init.lua")
  '';
}
