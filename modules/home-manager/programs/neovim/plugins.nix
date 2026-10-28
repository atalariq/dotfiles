# Plugins that are not packaged in nixpkgs, pinned in flake.nix as
# `flake = false`.
#
# Both consumers apply this with explicit arguments rather than importing it as a
# plain module: nvf replaces `inputs` inside its own module system with nvf's
# flake inputs, so our inputs can only be handed in from the outside.
{ pkgs, inputs }:
let
  # mdkite 2.x requires kitehost >= 2.0.
  kitehost = pkgs.vimUtils.buildVimPlugin {
    pname = "kitehost.nvim";
    version = "0-unstable-2026-10-01";
    src = inputs.kitehost-nvim;
  };
  mdkite = pkgs.vimUtils.buildVimPlugin {
    pname = "mdkite.nvim";
    version = "0-unstable-2026-10-02";
    src = inputs.mdkite-nvim;
    dependencies = [ kitehost ];
  };
in
{
  vim = {
    # The HTTP server must be on the packpath before mdkite loads, and lz.n
    # carries no dependency list, so it stays a start plugin while mdkite loads
    # on its own command.
    startPlugins = [ kitehost ];
    lazy.plugins."mdkite.nvim" = {
      package = mdkite;
      cmd = [
        "MdKite"
        "MdKite start"
      ];
    };
  };
}
