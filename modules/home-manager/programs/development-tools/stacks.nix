{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.dev;
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
    # job (T8). The enum value exists only to gate nvf's rust-analyzer (T6).
    rust = [ ];
    cc = [
      pkgs.clang
      pkgs.gcc14
      pkgs.cmake
      pkgs.ninja
      pkgs.pkg-config
      pkgs.gdb
      pkgs.lldb_20
      pkgs.bear
      pkgs.ccache
    ];
    # JVM/Dart CLI tools: Linux store only. On macpro the SDK layer is
    # Homebrew (flutter/dart/android-studio); nvf's languages.dart/java/kotlin
    # add their own nix tooling to the editor wrapper independently.
    java = lib.optionals isLinux [ pkgs.jdk21 ];
    kotlin = lib.optionals isLinux [ pkgs.kotlin ];
    dart = lib.optionals isLinux [ pkgs.dart ];
  };
in
{
  options.dotfiles.dev.stacks = lib.mkOption {
    type = with lib.types; listOf (enum stackTypes);
    default = [ ];
    example = [
      "node"
      "go"
      "rust"
    ];
    description = ''
      Language toolchains installed on PATH for this host. Also drives nvf
      language gating (see programs/neovim): one list, no drift.
    '';
  };

  config = lib.mkIf (cfg.stacks != [ ]) {
    assertions = [
      {
        assertion = cfg.stacks == lib.unique cfg.stacks;
        message = "dotfiles.dev.stacks: duplicate entries in ${toString cfg.stacks} — list each stack once";
      }
      # Fail loudly if stackTypes ever gains a value the map forgot (the enum
      # already rejects typos; this guards maintenance drift between the two).
      {
        assertion = builtins.all (s: builtins.hasAttr s stackPackages) stackTypes;
        message = "dotfiles.dev.stacks: stackTypes has a value missing from stackPackages — add the mapping";
      }
    ];

    home.packages = lib.flatten (map (s: stackPackages.${s} or [ ]) cfg.stacks);
  };
}
