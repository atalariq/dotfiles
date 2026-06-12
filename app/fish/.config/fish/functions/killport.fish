# ~/.config/fish/functions/killport.fish

function killport
    if test (count $argv) -eq 0
        echo "Usage: killport <port>"
        return 1
    end

    set -l port $argv[1]
    set -l pids (lsof -ti tcp:$port)

    if test -z "$pids"
        echo "No process found on port $port"
        return 0
    end

    echo "Killing process on port $port: $pids"
    kill -9 $pids
end
