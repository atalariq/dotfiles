status is-interactive; or return

if command -q yazi
    # change directory
    function yazicd
        set -l tmp (mktemp -t "yazi-cwd.XXXXX"); or return
        yazi $argv --cwd-file="$tmp"
        if set -l cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
            cd -- "$cwd"
        end
        command rm -f -- "$tmp"
    end

    abbr fm yazi
    abbr yy yazicd
end
