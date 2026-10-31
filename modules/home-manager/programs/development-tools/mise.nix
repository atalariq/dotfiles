{
  config,
  lib,
  ...
}:
{
  options.dotfiles.programs.development.mise.enable =
    lib.mkEnableOption "mise (per-project runtimes + task runner layer)";

  config = lib.mkIf config.dotfiles.programs.development.mise.enable {
    programs.mise = {
      enable = true;
      # Shell integration follows the module's own defaults (each
      # enableXIntegration defaults to that shell's enable). No globalConfig
      # pins: the empty global config is the contract; projects pin their own.
      #
      # Nix-per-project bridge: https://github.com/jbadeau/mise-nix lets mise
      # read a project's flake.nix (devShell/flake) and activate it on cd —
      # the mise-side twin of `use flake`, and the recommended hook when a
      # repo wants Nix while the team contract stays mise.toml-first. Install
      # at runtime (state, not git):  mise plugins install mise-nix
      # Binary caches for whatever that nix-evals live in
      # modules/nix-cache.nix (cache.nixos.org, nix-community, ...).
    };
  };
}
