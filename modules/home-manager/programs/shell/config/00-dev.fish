# Portable paths; project environments and existing runtime settings take priority.
set -q XDG_CONFIG_HOME; or set -gx XDG_CONFIG_HOME "$HOME/.config"
set -q XDG_CACHE_HOME; or set -gx XDG_CACHE_HOME "$HOME/.cache"
set -q XDG_DATA_HOME; or set -gx XDG_DATA_HOME "$HOME/.local/share"
set -q XDG_STATE_HOME; or set -gx XDG_STATE_HOME "$HOME/.local/state"

set -q LOCAL_BIN; or set -gx LOCAL_BIN "$HOME/.local/bin"
set -q LOCAL_SCRIPT; or set -gx LOCAL_SCRIPT "$HOME/.local/script"
set -q GOPATH; or set -gx GOPATH "$HOME/.go"
set -q GOBIN; or set -gx GOBIN "$GOPATH/bin"
set -q CARGO_HOME; or set -gx CARGO_HOME "$HOME/.cargo"
set -q RUSTUP_HOME; or set -gx RUSTUP_HOME "$HOME/.rustup"
set -q PNPM_HOME; or set -gx PNPM_HOME "$XDG_DATA_HOME/pnpm"
set -q BUN_INSTALL; or set -gx BUN_INSTALL "$HOME/.bun"
set -q DENO_INSTALL; or set -gx DENO_INSTALL "$HOME/.deno"
set -q UV_LINK_MODE; or set -gx UV_LINK_MODE copy
if test -f "$XDG_CONFIG_HOME/python/pythonrc"
    set -gx PYTHONSTARTUP "$XDG_CONFIG_HOME/python/pythonrc"
end

# Append existing user directories; never prepend global toolchains over a project.
for directory in "$GOBIN" "$CARGO_HOME/bin" "$PNPM_HOME" "$BUN_INSTALL/bin" "$DENO_INSTALL/bin" "$LOCAL_BIN" "$LOCAL_SCRIPT"
    if test -d "$directory"; and not contains -- "$directory" $PATH
        set -gx PATH $PATH "$directory"
    end
end
