# ~/.config/fish/functions/gclean-branches.fish

function gclean-branches
    git fetch --all --prune

    set -l branches (git branch -vv | awk '/: gone]/{print $1}')

    if test (count $branches) -eq 0
        echo "No gone branches."
        return 0
    end

    printf "%s\n" $branches
    read -l -P "Delete these branches? [y/N] " confirm

    if test "$confirm" = y
        git branch -D $branches
    else
        echo "Cancelled."
    end
end
