# ~/.config/fish/functions/serve.fish

function serve
    set -l port 8000

    if test (count $argv) -ge 1
        set port $argv[1]
    end

    python -m http.server $port
end
