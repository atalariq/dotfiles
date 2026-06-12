# ~/.config/fish/functions/gclone.fish

function gclone
    if test (count $argv) -eq 0
        echo "Usage: gclone <repo-url>"
        return 1
    end

    git clone $argv[1]
    and cd (basename $argv[1] .git)
end
