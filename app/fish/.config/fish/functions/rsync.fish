function cpr --description "rsync as cp alternative"
    rsync --archive -hh --partial --info=stats1,progress2 --modify-window=1 $argv
end

function mvr --description "rsync as mv alternative"
    rsync --archive -hh --partial --info=stats1,progress2 --modify-window=1 --remove-source-files $argv
end
