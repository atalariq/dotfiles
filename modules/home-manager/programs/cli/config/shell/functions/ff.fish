function ff --description "Fuzzy-find a file and print it (bat preview, full dump to stdout)"
    if not command -q fzf
        return 1
    end
    set -l file (fd --type f $argv | fzf --preview 'bat --color=always --line-range :500 {}')
    if test -n "$file"
        bat --color=always "$file"
    end
end
