# ~/.config/fish/functions/path-clean.fish

function path-clean
    set -l clean_path

    for dir in $PATH
        if test -d "$dir"; and not contains "$dir" $clean_path
            set clean_path $clean_path "$dir"
        end
    end

    set -gx PATH $clean_path
    printf "%s\n" $PATH
end
