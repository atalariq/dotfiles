#!/usr/bin/env sh
# secrets-load — decrypt SOPS/age secrets and export them.
# Source from ~/.profile (bash/zsh). Fish calls it via a wrapper.
# Requires: sops, age/rage. See docs/secrets.md.

export SOPS_AGE_KEY_FILE="${SOPS_AGE_KEY_FILE:-${HOME}/.config/age/keys.txt}"

_secrets_file="${SECRETS_FILE:-${HOME}/.config/sops/secrets.yaml}"

[ -f "$_secrets_file" ] || return 0 2>/dev/null || exit 0
command -v sops >/dev/null 2>&1 || return 0 2>/dev/null || exit 0

eval "$(sops -d --output-type dotenv "$_secrets_file" 2>/dev/null |
	sed -n '/^[A-Za-z_][A-Za-z0-9_]*=/{ s/^/export /; p; }')"

unset _secrets_file
