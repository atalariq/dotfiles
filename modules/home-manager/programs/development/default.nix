# The `dotfiles.programs.development` group kernel: imports the development
# tool modules and owns `stacks` - the one list declaring which technologies this host
# actually works in. Stacks drive three consumers and must never drift:
#
#   - PATH toolchains        (installed right here)
#   - nvf language support   (modules/nvf/langs.nix)
#   - JetBrains IDEs         (jetbrains.nix derives them from these stacks)
#
# Values with an empty package list are EDITOR/IDE GATES ONLY (they install no
# runtime): `rust` per decision T8 (mise owns toolchains), and the web/SQL/data
# languages whose runtimes live per-project (containers, mise) - enabling them
# selects LSPs and IDEs, never PATH tools.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.programs.development;
  stackTypes = [
    "node"
    "bun"
    "python"
    "go"
    "rust"
    "cc"
    "java"
    "kotlin"
    "dart"
    "php"
    "vue"
    "svelte"
    "sql"
  ];
  isLinux = pkgs.stdenv.hostPlatform.isLinux;

  # One map, one truth: every stack value names its PATH packages here.
  # An empty list means "gates editor/tooling only, installs nothing".
  stackPackages = {
    node = [
      pkgs.nodejs_24 # corepack/npm usable via env already set in 00-dev.fish
    ];
    bun = [ pkgs.bun ];
    python = [
      pkgs.python3
      pkgs.uv
    ];
    go = [ pkgs.go ];
    # rust deliberately installs NOTHING: per-project toolchains are mise's
    # job (T8). The enum value gates nvf's rust-analyzer and RustRover.
    rust = [ ];
    cc = [
      # gcc owns cc/c++/cpp: clang-wrapper and gcc-wrapper ship identical
      # subpaths and buildEnv rejects equal-priority collisions (this broke
      # thinkpad activation once - always build home.activationPackage after
      # changing stacks). clang stays fully available as clang/clang++.
      (lib.hiPrio pkgs.gcc14)
      pkgs.clang
      pkgs.cmake
      pkgs.ninja
      pkgs.pkg-config
      pkgs.gdb
      pkgs.lldb_20
      pkgs.bear
      pkgs.ccache
    ];
    # JVM/Dart CLI tools: Linux store only. On the Mac mini the SDK layer is
    # Homebrew (flutter/dart/android-studio); nvf's languages and the IDE
    # derivation add their own tooling independently.
    java = lib.optionals isLinux [ pkgs.jdk21 ];
    kotlin = lib.optionals isLinux [ pkgs.kotlin ];
    dart = lib.optionals isLinux [ pkgs.dart ];
    # Gate-only: Laravel runs in containers (Sail/compose), Vue/Svelte/SQL
    # tooling is per-project; the values select nvf language servers and,
    # for php, PhpStorm (see jetbrains.nix).
    php = [ ];
    vue = [ ];
    svelte = [ ];
    sql = [ ];
  };
in
{
  imports = import ../_import-category.nix {
    inherit lib;
    dir = ./.;
  };

  options.dotfiles.programs.development.stacks = lib.mkOption {
    type = with lib.types; listOf (enum stackTypes);
    default = [ ];
    example = [
      "node"
      "go"
      "rust"
    ];
    description = ''
      Technologies this host works in. Drives PATH toolchains, nvf language
      gating (see `modules/nvf/langs.nix`) and the JetBrains IDE derivation -
      one list, no drift.
    '';
  };

  config = lib.mkIf (cfg.stacks != [ ]) {
    assertions = [
      {
        assertion = cfg.stacks == lib.unique cfg.stacks;
        message = "dotfiles.programs.development.stacks: duplicate entries in ${toString cfg.stacks} - list each stack once";
      }
      # Fail loudly if stackTypes ever gains a value the map forgot (the enum
      # already rejects typos; this guards maintenance drift between the two).
      {
        assertion = builtins.all (s: builtins.hasAttr s stackPackages) stackTypes;
        message = "dotfiles.programs.development.stacks: stackTypes has a value missing from stackPackages - add the mapping";
      }
    ];

    home.packages = lib.flatten (map (s: stackPackages.${s} or [ ]) cfg.stacks);
  };
}
