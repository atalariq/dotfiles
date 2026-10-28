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
  #
  # Modules are ordered by concern and each header maps it to the Lua files it
  # drives. Read modules/00-core.nix first: it documents which options nvf sets
  # at build time versus which ones the Lua tree owns at runtime.
  configured = inputs.nvf.lib.neovimConfiguration {
    inherit pkgs;
    modules = [
      ./modules/00-core.nix
      ./modules/10-ui.nix
      ./modules/20-plugins.nix
      ./modules/30-lsp.nix
      ./modules/40-languages.nix
      (import ./modules/90-runtime.nix { inherit runtime configSource liveRuntime; })
    ];
  };
in
configured.neovim
