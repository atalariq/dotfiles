function less
    # Bohongi less bahwa kita pakai terminal xterm biasa
    # agar dia tidak mencoba pakai fitur advanced Kitty yang bikin error
    set -lx TERM xterm-256color
    command less $argv
end

