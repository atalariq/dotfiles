function take --description "Create a directory and enter it."
    set folder $argv[1]
    mkdir -p $folder
    cd $folder
end
