function todo --description "Open TODO.md file"
    if not set -q $EDITOR
        set EDITOR nvim
    end

    set todofile (if test -f "$PWD/TODO.md"; echo "$PWD/TODO.md"; else; echo "$HOME/TODO.md"; end)

    $EDITOR $todofile
end
