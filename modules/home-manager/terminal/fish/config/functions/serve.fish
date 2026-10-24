# ~/.config/fish/functions/serve.fish

function serve
    set -l port 8000

    if test (count $argv) -ge 1
        set port $argv[1]
    end

    if not command -q miniserve
        echo 'serve: miniserve belum tersedia; build dan apply konfigurasi Nix terlebih dahulu.' >&2
        return 127
    end
    command miniserve --port "$port" --index index.html --hidden --verbose -- .
end
