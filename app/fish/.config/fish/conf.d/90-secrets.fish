# ~/.config/fish/conf.d/secrets.fish
# Requires: sops, age/rage, bash

function load_secrets
    set -l encrypted "$HOME/.config/fish/secrets.yaml"

    if not test -f "$encrypted"
        echo "Secrets file not found: $encrypted"
        return 1
    end

    if not command -q sops
        echo "sops is not installed."
        return 1
    end

    if not command -q bash
        echo "bash is not installed."
        return 1
    end

    set -l tmp_dotenv (mktemp)
    set -l tmp_dump (mktemp)

    chmod 600 "$tmp_dotenv" "$tmp_dump"

    if not sops -d --output-type dotenv "$encrypted" > "$tmp_dotenv"
        command rm -f "$tmp_dotenv" "$tmp_dump"
        echo "Failed to decrypt secrets."
        return 1
    end

    bash -c '
        set -euo pipefail

        dotenv="$1"

        mapfile -t keys < <(
            grep -E "^[A-Za-z_][A-Za-z0-9_]*=" "$dotenv" \
                | sed -E "s/=.*$//"
        )

        set -a
        source "$dotenv"
        set +a

        for key in "${keys[@]}"; do
            printf "%s\0%s\0" "$key" "${!key-}"
        done
    ' bash "$tmp_dotenv" > "$tmp_dump"

    while read --null key
        read --null val
        if test -n "$key"
            set -gx "$key" "$val"
        end
    end < "$tmp_dump"

    command rm -f "$tmp_dotenv" "$tmp_dump"

    set -gx __SECRETS_LOADED 1
    echo "Secrets loaded."
end

function unload_secrets
    set -l encrypted "$HOME/.config/fish/secrets.yaml"

    if not test -f "$encrypted"
        return 1
    end

    set -l tmp_dotenv (mktemp)
    chmod 600 "$tmp_dotenv"

    if not sops -d --output-type dotenv "$encrypted" > "$tmp_dotenv"
        command rm -f "$tmp_dotenv"
        echo "Failed to decrypt secrets."
        return 1
    end

    set -l keys (
        grep -E "^[A-Za-z_][A-Za-z0-9_]*=" "$tmp_dotenv" \
            | sed -E "s/=.*\$//"
    )

    for key in $keys
        set -e "$key"
    end

    set -e __SECRETS_LOADED
    command rm -f "$tmp_dotenv"

    echo "Secrets unloaded."
end

function secrets-status
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
