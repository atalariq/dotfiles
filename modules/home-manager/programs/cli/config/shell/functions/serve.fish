function serve --description "Serve the current directory over HTTP (default port 8000)"
    if not command -q python3
        echo "serve needs python3 (enable the python dev stack)" >&2
        return 1
    end
    set -l port 8000
    if test (count $argv) -ge 1
        set port $argv[1]
    end
    python3 -m http.server $port
end
