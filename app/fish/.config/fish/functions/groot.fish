# ~/.config/fish/functions/groot.fish

function groot
    set -l root (git rev-parse --show-toplevel 2>/dev/null)

    if test -z "$root"
        echo "Not inside a Git repository."
        return 1
    end

    cd "$root"
end
