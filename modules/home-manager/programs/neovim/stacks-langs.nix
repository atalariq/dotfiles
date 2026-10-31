# Heavy language support, gated by `dotfiles.dev.stacks` (T5).
#
# Curried like `runtime-layer.nix`: the outer argument is ours, the inner one is
# supplied by nvf's module system, which is where `lib` comes from. Every entry
# here is therefore invisible unless a host selected its stack, so PATH
# toolchains and nvf's language servers never drift apart.
{ stacks }:
{ lib, ... }:
let
  heavy = {
    node = {
      typescript.enable = true;
      tsx.enable = true;
    };
    python = {
      python = {
        enable = true;
        format.type = [ "ruff" ];
      };
    };
    go = {
      go = {
        enable = true;
        format.type = [ "gofumpt" ];
        # dlv/nvim-dap-go; gated here because it must follow the host's stack.
        dap.enable = true;
      };
    };
    # rust-analyzer only: nvf's rust module does not add rustc/cargo to the
    # wrapper, so mise's per-project toolchains are never PATH-shadowed.
    rust.rust.enable = true;
    cc.clang.enable = true;
    java.java.enable = true;
    kotlin.kotlin.enable = true;
    dart.dart.enable = true;
    # bun is a PATH toolchain only (stacks.nix); it has no nvf language module.
    bun = { };
  };
in
{
  vim.languages = lib.mkMerge (map (s: heavy.${s} or { }) stacks);
}
