# secrets.fish — delegates to secrets.sh via bash subprocess
# Requires: sops, age/rage, bash
# See docs/secrets.md for setup instructions

function load_secrets
    set -l secrets_sh "$HOME/.config/fish/conf.d/secrets.sh"

    if not test -f "$secrets_sh"
        return 1
    end

    bash -c 'set -a; source "$1" >/dev/null 2>&1; env' _ "$secrets_sh" \
        | while read -l line
            string match -qr '^[A-Z][A-Z0-9_]*=' $line || continue
            set -l kv (string split -m1 = $line)
            test (count $kv) -eq 2 || continue
            set -gx $kv[1] $kv[2]
        end
end

if status is-interactive
    load_secrets
end
