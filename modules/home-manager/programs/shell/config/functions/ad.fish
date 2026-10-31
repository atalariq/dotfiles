function ad --description "Create files or directories, with parents"
    for file in $argv
        switch $file
            case '*/'
                mkdir -p -- $file
            case '*'
                mkdir -p -- (dirname -- $file)
                touch -- $file
        end
    end
end
