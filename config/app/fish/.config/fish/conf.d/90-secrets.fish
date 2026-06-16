# ~/.config/fish/conf.d/90-secrets.fish
# Thin wrapper over the shared POSIX loader (~/.local/script/secrets-load).
# Requires: sops, age/rage, bash.

set -g __SECRETS_LOADER "$HOME/.local/script/secrets-load"
set -g __SECRETS_STORE "$HOME/.config/sops/secrets.yaml"

function load_secrets --description "Decrypt and export secrets into fish"
    if not test -f "$__SECRETS_STORE"
        echo "Secrets file not found: $__SECRETS_STORE"
        return 1
    end
    if not command -q sops; or not command -q bash
        echo "sops and bash are required."
        return 1
    end

    set -l tmp (mktemp)
    chmod 600 "$tmp"
    bash -c '
        set -euo pipefail
        SECRETS_FILE="'"$__SECRETS_STORE"'"
        . "'"$__SECRETS_LOADER"'"
        sops -d --output-type dotenv "$SECRETS_FILE" 2>/dev/null \
          | grep -E "^[A-Za-z_][A-Za-z0-9_]*=" \
          | sed -E "s/=.*$//" \
          | while read -r k; do printf "%s\0%s\0" "$k" "${!k-}"; done
    ' > "$tmp"

    while read --null key; read --null val
        test -n "$key"; and set -gx "$key" "$val"
    end < "$tmp"
    command rm -f "$tmp"
    set -gx __SECRETS_LOADED 1
    echo "Secrets loaded."
end

function unload_secrets --description "Remove exported secrets from fish"
    test -f "$__SECRETS_STORE"; or return 1
    for key in (sops -d --output-type dotenv "$__SECRETS_STORE" 2>/dev/null | grep -E "^[A-Za-z_][A-Za-z0-9_]*=" | sed -E 's/=.*$//')
        set -e "$key"
    end
    set -e __SECRETS_LOADED
    echo "Secrets unloaded."
end

function secrets-status --description "Show whether secrets are loaded"
    if set -q __SECRETS_LOADED
        echo "Secrets are loaded."
    else
        echo "Secrets are not loaded."
    end
end

if status is-interactive
    if not set -q __SECRETS_LOADED
        load_secrets >/dev/null
    end
end
