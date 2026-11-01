function todo --description "Open TODO.md: current project first, else home"
    set -l todofile $HOME/TODO.md
    if test -f $PWD/TODO.md
        set todofile $PWD/TODO.md
    end
    $EDITOR $todofile
end
