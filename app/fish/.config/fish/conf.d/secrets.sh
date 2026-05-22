# secrets.sh — POSIX-compatible secrets loader
# Source from ~/.profile or ~/.bashrc
# Requires: sops, age/rage
# See docs/secrets.md for setup instructions

export SOPS_AGE_KEY_FILE="${SOPS_AGE_KEY_FILE:-${HOME}/.config/age/keys.txt}"

_load_secrets() {
    _SECRETS_FILE="${HOME}/.config/fish/secrets.yaml"

    [ -f "$_SECRETS_FILE" ] || return 0
    command -v sops >/dev/null 2>&1 || return 0

    eval "$(sops -d --output-type dotenv "$_SECRETS_FILE" 2>/dev/null | sed -n '/^[A-Z_][A-Z0-9_]*=/{ s/^/export /; p; }')"
}

_load_secrets
unset _load_secrets _SECRETS_FILE
