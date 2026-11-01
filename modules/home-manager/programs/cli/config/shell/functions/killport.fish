function killport --description "Kill the process listening on a TCP port"
    if test (count $argv) -eq 0
        echo "usage: killport <port>" >&2
        return 1
    end
    if command -q lsof
        set -l pids (lsof -ti tcp:$argv[1])
        if test (count $pids) -eq 0
            echo "nothing listening on tcp:$argv[1]" >&2
            return 1
        end
        kill -- $pids
    else if command -q fuser
        fuser -k -n tcp $argv[1]
    else
        echo "killport needs lsof or fuser" >&2
        return 1
    end
end
