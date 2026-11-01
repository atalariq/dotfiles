# Language support gated by `dotfiles.programs.development.stacks`.
#
# Curried like `runtime-layer.nix`: the outer argument is ours, the inner one is
# supplied by nvf's module system, which is where `lib` comes from. Every entry
# here is therefore invisible unless a host selected its stack, so PATH
# toolchains and nvf's language servers never drift apart.
#
# The gate-only entries (php, vue, svelte, sql) are deliberate: their runtimes
# stay per-project (containers, mise), but the host declared the technology, so
# editor tooling follows the declaration instead of being baked in uncondition-
# ally for every machine.
{ stacks }:
{ lib, ... }:
let
  heavy = {
    node = {
      # vtsls is the single TypeScript server (legacy parity). Leaving the
      # module default enabled would run typescript-language-server at the same
      # time; vtsls is enabled below for node/bun hosts.
      typescript = {
        enable = true;
        lsp.servers = [ ];
      };
      tsx = {
        enable = true;
        lsp.servers = [ ];
      };
    };
    python = {
      python = {
        enable = true;
        format.type = [ "ruff" ];
        dap.enable = true;
      };
    };
    go = {
      go = {
        enable = true;
        format = {
          enable = true;
          type = [
            "goimports"
            "gofumpt"
          ];
        };
        # dlv/nvim-dap-go; gated here because it must follow the host's stack.
        dap.enable = true;
      };
    };
    # rust-analyzer only: nvf's rust module does not add rustc/cargo to the
    # wrapper, so mise's per-project toolchains are never PATH-shadowed.
    rust.rust = {
      enable = true;
      dap.enable = true;
    };
    cc.clang = {
      enable = true;
      dap.enable = true;
    };
    java.java.enable = true;
    kotlin.kotlin.enable = true;
    dart.dart.enable = true;
    php.php.enable = true; # Laravel work; runtime lives in containers (Sail/compose)
    vue.vue.enable = true; # Vue3 frontend work
    svelte.svelte.enable = true;
    sql.sql.enable = true; # coursework/DB work; clients likewise per-project
    # bun is a PATH toolchain only (the stacks kernel); it has no nvf language
    # module - node's typescript coverage serves bun projects.
    bun = { };
  };
  usesTypescript = builtins.elem "node" stacks || builtins.elem "bun" stacks;
in
{
  vim = lib.mkMerge [
    { languages = lib.mkMerge (map (s: heavy.${s} or { }) stacks); }
    (lib.mkIf usesTypescript {
      lsp.presets.vtsls.enable = true;
    })
  ];
}
