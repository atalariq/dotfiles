# The live tree is native Neovim data: after/ftplugin overrides, after/queries,
# snippets and editor tool config. Editor behavior (options, maps, autocmds,
# plugins) is declared in Nix; changing that requires a rebuild.
#
# Curried like the other kernel modules: the outer argument is ours, the inner
# one is supplied by nvf's module system.
{ runtime }:
_: {
  vim.additionalRuntimePaths = [
    {
      path = runtime;
      position = "prepend";
    }
    {
      path = "${runtime}/after";
      position = "append";
    }
  ];
}
