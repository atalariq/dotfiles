function take --description "Create a directory and enter it"
    if test (count $argv) -eq 0
        echo "usage: take <dir>" >&2
        return 1
    end
    mkdir -p -- $argv
    cd -- $argv[1]
end
