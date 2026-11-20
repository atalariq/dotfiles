# The single implementation of "live checkout or this generation's copy".
#
# Every module that links native configuration makes the same decision: in live
# mode point at the checkout so edits apply without a rebuild, otherwise point at
# the store copy. Ten modules had this copied verbatim; this is the one copy.
{ config }:
path: relative:
if config.dotfiles.deployment.mode == "live" then
  config.lib.file.mkOutOfStoreSymlink "${config.dotfiles.deployment.checkout}/${relative}"
else
  path
