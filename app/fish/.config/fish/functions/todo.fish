function todo --description "Open ~/TODO.md"
    if not set -q $EDITOR
        set EDITOR nvim
    end
    $EDITOR $HOME/TODO.md
end
