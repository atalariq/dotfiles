# ~/.config/fish/functions/backup.fish

function backup
    if test (count $argv) -eq 0
        echo "Usage: backup <file-or-directory>"
        return 1
    end

    set -l target $argv[1]

    if not test -e "$target"
        echo "Not found: $target"
        return 1
    end

    set -l timestamp (date +"%Y%m%d-%H%M%S")
    cp -a "$target" "$target.bak-$timestamp"
end
