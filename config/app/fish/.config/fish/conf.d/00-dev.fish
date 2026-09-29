# ~/.config/fish/conf.d/dev.fish
# Developer environment config

# ── XDG paths ──────────────────────────────────────────---
set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx XDG_CACHE_HOME "$HOME/.cache"
set -gx XDG_DATA_HOME "$HOME/.local/share"
set -gx XDG_STATE_HOME "$HOME/.local/state"

# ── Local Paths ────────────────────────────────────────
set -gx LOCAL_BIN "$HOME/.local/bin"
set -gx LOCAL_SCRIPT "$HOME/.local/script"

# --- Arch Linux Specific ----------------------------------
if test -f /etc/os-release
  if string match -q "*Arch Linux*" (cat /etc/os-release)
    # ── Java ─────────────────────────────────────────────-
    set -gx JAVA_HOME /usr/lib/jvm/java-21-openjdk

    # ── Flutter / FVM ────────────────────────────────────
    set -gx CHROME_EXECUTABLE /usr/bin/google-chrome-stable
    set -gx FVM_CACHE_PATH "$HOME/.fvm"

    # ── Android SDK ────────────────────────────────────────---
    set -gx ANDROID_HOME "$HOME/Android/Sdk"
    set -gx ANDROID_SDK_ROOT "$ANDROID_HOME"
  end
end

# ── Go ─────────────────────────────────────────────────---
set -gx GOPATH "$HOME/.go"
set -gx GOBIN "$GOPATH/bin"
set -gx GOFLAGS "-buildvcs=false"

# ── Rust ───────────────────────────────────────────────---
set -gx CARGO_HOME "$HOME/.cargo"
set -gx RUSTUP_HOME "$HOME/.rustup"

# ── Node / Package Managers ────────────────────────────---
set -gx COREPACK_ENABLE_DOWNLOAD_PROMPT 0
set -gx PNPM_HOME "$XDG_DATA_HOME/pnpm"
set -gx BUN_INSTALL "$HOME/.bun"

# ── Python ─────────────────────────────────────────────---
set -gx PYTHONSTARTUP "$XDG_CONFIG_HOME/python/pythonrc"
set -gx UV_LINK_MODE copy

# ── Deno ───────────────────────────────────────────────---
set -gx DENO_INSTALL "$HOME/.deno"

# # ── Agent / AI Tooling ─────────────────────────────────---
# set -gx DO_NOT_TRACK        1
# set -gx HERMES_TUI          0
# set -gx OPENCODE_ENABLE_EXA 1
# set -gx OPENSPEC_TELEMETRY  0
# set -gx MNEMOSYNE_DATA_DIR  "$HOME/.mnemosyne/data"

# ── PATH ───────────────────────────────────────────────
fish_add_path "$JAVA_HOME/bin"

fish_add_path "$ANDROID_HOME/cmdline-tools/latest/bin"
fish_add_path "$ANDROID_HOME/platform-tools"

fish_add_path "$GOBIN"
fish_add_path "$CARGO_HOME/bin"
fish_add_path "$PNPM_HOME/bin"
fish_add_path "$BUN_INSTALL/bin"
fish_add_path "$DENO_INSTALL/bin"

fish_add_path "$FVM_CACHE_PATH/default/bin"

fish_add_path "$LOCAL_BIN"
fish_add_path "$LOCAL_SCRIPT"
