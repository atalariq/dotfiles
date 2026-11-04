# Stack -> JetBrains IDE data. Hosts still write the IDE packages in their
# `apps.nix` (one visible list, no hidden derivation), but this map keeps a
# host from silently declaring a stack without the matching editor. The
# assertion in the NixOS host module compares `expected` with `apps.gui`.
{
  pkgs,
  lib,
}:
let
  byStack = {
    go = pkgs.jetbrains.goland;
    node = pkgs.jetbrains.webstorm;
    bun = pkgs.jetbrains.webstorm;
    rust = pkgs.jetbrains.rust-rover;
    php = pkgs.jetbrains.phpstorm;
    java = pkgs.jetbrains.idea;
    kotlin = pkgs.jetbrains.idea;
    dart = pkgs.jetbrains.idea;
  };
in
{
  inherit byStack;

  # Stacks without an IDE mapping (python, cc, vue, svelte, sql) are ignored.
  expected =
    stacks:
    lib.unique (
      map (stack: byStack.${stack}) (builtins.filter (stack: builtins.hasAttr stack byStack) stacks)
    );
}
