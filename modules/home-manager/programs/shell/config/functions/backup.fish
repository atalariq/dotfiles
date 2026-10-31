function backup --description "Copy <path> to <path>.bak-<timestamp>"
    if test (count $argv) -eq 0
        echo "usage: backup <path>" >&2
        return 1
    end
    set -l target $argv[1]
    if not test -e $target
        echo "not found: $target" >&2
        return 1
    end
    set -l timestamp (date +%Y%m%d-%H%M%S)
    cp -a -- $target "$target.bak-$timestamp"
    echo "saved: $target.bak-$timestamp"
end
