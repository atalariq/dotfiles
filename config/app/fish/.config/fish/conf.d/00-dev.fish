# ~/.config/fish/conf.d/dev.fish
# Developer environment config

# ── Android SDK ────────────────────────────────────────
set -gx ANDROID_HOME "$HOME/Dev/android-sdk"
set -gx ANDROID_SDK_ROOT "$ANDROID_HOME"

# ── Java ───────────────────────────────────────────────
set -gx JAVA_HOME /usr/lib/jvm/java-21-openjdk

# ── Flutter / FVM ──────────────────────────────────────
set -gx CHROME_EXECUTABLE /usr/bin/google-chrome-stable
set -gx FVM_CACHE_PATH "$HOME/Dev/fvm"

# ── Go ─────────────────────────────────────────────────
set -gx GOPATH "$HOME/Dev/go"
set -gx GOBIN "$GOPATH/bin"
set -gx GOFLAGS "-buildvcs=false"

# ── Rust ───────────────────────────────────────────────
set -gx CARGO_HOME "$HOME/.cargo"
set -gx RUSTUP_HOME "$HOME/.rustup"

# ── Node / Package Managers ────────────────────────────
set -gx COREPACK_ENABLE_DOWNLOAD_PROMPT 0
set -gx PNPM_HOME "$HOME/.local/share/pnpm"
set -gx BUN_INSTALL "$HOME/.bun"

# ── Python ─────────────────────────────────────────────
set -gx PYTHONSTARTUP "$HOME/.config/python/pythonrc"
set -gx UV_LINK_MODE copy

# ── Deno ───────────────────────────────────────────────
set -gx DENO_INSTALL "$HOME/.deno"

# ── Agent / AI Tooling ─────────────────────────────────
set -gx DO_NOT_TRACK        1
set -gx HERMES_TUI          0
set -gx OPENCODE_ENABLE_EXA 1
set -gx OPENSPEC_TELEMETRY  0
set -gx MNEMOSYNE_DATA_DIR  "$HOME/.mnemosyne/data"

# -- Tooling --------------------------------------------
set -gx VALE_CONFIG_PATH $HOME/.config/vale/.vale.ini

# ── Local Paths ────────────────────────────────────────
set -gx LOCAL_BIN "$HOME/.local/bin"
set -gx LOCAL_SCRIPT "$HOME/.local/script"

# ── PATH ───────────────────────────────────────────────
fish_add_path --path "$JAVA_HOME/bin"

fish_add_path --path "$ANDROID_HOME/cmdline-tools/latest/bin"
fish_add_path --path "$ANDROID_HOME/platform-tools"

fish_add_path --path "$GOBIN"
fish_add_path --path "$CARGO_HOME/bin"
fish_add_path --path "$PNPM_HOME"
fish_add_path --path "$BUN_INSTALL/bin"
fish_add_path --path "$DENO_INSTALL/bin"

fish_add_path --path "$FVM_CACHE_PATH/default/bin"

fish_add_path --path "$LOCAL_BIN"
fish_add_path --path "$LOCAL_SCRIPT"
