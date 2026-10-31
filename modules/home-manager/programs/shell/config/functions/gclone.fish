function gclone --description "Clone a repo and cd into it"
    if test (count $argv) -eq 0
        echo "usage: gclone <repo-url>" >&2
        return 1
    end
    git clone -- $argv[1]
    and cd -- (basename $argv[1] .git)
end
