# ~/.config/fish/functions/path-show.fish

function path-show
    for p in $PATH
        echo $p
    end
end
