# Managing my secrets
# Tools used: age/rage, sops

set -gx SOPS_AGE_KEY_FILE $HOME/.config/age/keys.txt

function load_secrets
    set encrypted $HOME/.config/fish/secrets.yaml

    if not test -f $encrypted
        return 1
    end

    # Decrypt to a temp variable, parse each line
    set decrypted (sops -d --output-type dotenv $encrypted)

    for line in $decrypted
        # Skip empty lines and comments
        if string match -qr '^[A-Z]' $line
            set key (string split -m1 '=' $line)[1]
            set val (string split -m1 '=' $line)[2]
            set -gx $key $val
        end
    end
end

if status is-interactive
    load_secrets
end
