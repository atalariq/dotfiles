{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.programs.development.jetbrains;

  # One map, one truth: the host's `dotfiles.programs.development.stacks` decide which IDEs
  # exist. This replaced the per-IDE flags (owner decision 2026-10-31): a host
  # that declares a stack works in it seriously, and the matching IDE follows.
  # Hosts that only ever touch Python or C from the editor simply do not carry
  # those stacks, so no mapping entry is derived for them.
  #
  #   go          -> goland
  #   node, bun   -> webstorm        (deduped)
  #   rust        -> rust-rover      (rust stack is editor-gate only)
  #   php         -> phpstorm        (gate-only; runtime is containers)
  #   java, kotlin, dart -> idea     (IDEA Ultimate: the owner's licence covers
  #                                  it; every other IDE in the map is paid too)
  #
  # python/cc have no entry on purpose: the owner works them in Neovim.
  # `excludes` opts a declared stack's IDE back out when a host wants the
  # toolchain without the editor (the stack list drives more than this).
  idesByStack = {
    go = pkgs.jetbrains.goland;
    node = pkgs.jetbrains.webstorm;
    bun = pkgs.jetbrains.webstorm;
    rust = pkgs.jetbrains.rust-rover;
    php = pkgs.jetbrains.phpstorm;
    java = pkgs.jetbrains.idea;
    kotlin = pkgs.jetbrains.idea;
    dart = pkgs.jetbrains.idea;
  };
  derivedIdes = lib.unique (
    map (s: idesByStack.${s}) (
      builtins.filter (s: !builtins.elem s cfg.excludes) (
        # stacks that have a mapping; filter keeps host order and skips the
        # stacks intentionally left unmapped (python, cc, vue, svelte, sql).
        builtins.filter (s: builtins.hasAttr s idesByStack) config.dotfiles.programs.development.stacks
      )
    )
  );
in
{
  # Master gate stays: the derivation must never install IDEs into a host that
  # did not ask for the bundle (headless lab hosts share stack names with
  # desktops). enable = true alone with no mapped stack still installs nothing.
  options.dotfiles.programs.development.jetbrains = {
    enable = lib.mkEnableOption "the JetBrains IDE bundle derived from dotfiles.programs.development.stacks";
    excludes = lib.mkOption {
      type = with lib.types; listOf (enum (builtins.attrNames idesByStack));
      default = [ ];
      example = [ "bun" ];
      description = "Stacks whose IDE to drop despite the stack being declared.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.excludes == lib.unique cfg.excludes;
        message = "jetbrains.excludes: list each stack once";
      }
    ];
    home.packages = derivedIdes;
  };
}
