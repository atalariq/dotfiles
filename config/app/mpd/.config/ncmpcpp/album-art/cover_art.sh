#!/usr/bin/env bash
# Cover art script for ncmpcpp

# SETTINGS
music_library=$HOME/Music
fallback_image="$HOME/.config/ncmpcpp/album-art/fallback.png"

max_width=40
force_square="false"

padding_left=2
padding_right=2
padding_top=1
padding_bottom=0

# Only set this if the geometries are wrong or ncmpcpp shouts at you to do it.
# Visually select/highlight a character on your terminal, zoom in an image 
# editor and count how many pixels a character's width and height are.
# font_height=20
# font_width=8

main() {
    kill_previous_instances >/dev/null 2>&1
    find_cover_image        >/dev/null 2>&1
    display_cover_image     2>/dev/null
    detect_window_resizes   >/dev/null 2>&1
}

# ==== Main functions =========================================================

kill_previous_instances() {
    script_name=$(basename "$0")
    for pid in $(pidof -x "$script_name"); do
        if [ "$pid" != $$ ]; then
            kill -15 "$pid"
        fi 
    done
}

find_cover_image() {

    # First we check if the audio file has an embedded album art
    ext="$(mpc --format %file% current | sed 's/^.*\.//')"
    if [ "$ext" = "flac" ]; then
        # since FFMPEG cannot export embedded FLAC art we use metaflac
        metaflac --export-picture-to=/tmp/mpd_cover.jpg \
            "$(mpc --format "$music_library"/%file% current)" &&
            cover_path="/tmp/mpd_cover.jpg" && return
    else
        ffmpeg -y -i "$(mpc --format "$music_library"/%file% | head -n 1)" \
            /tmp/mpd_cover.jpg &&
            cover_path="/tmp/mpd_cover.jpg" && return
    fi

    # If no embedded art was found we look inside the music file's directory
    album="$(mpc --format %album% current)"
    file="$(mpc --format %file% current)"
    album_dir="${file%/*}"
    album_dir="$music_library/$album_dir"
    found_covers="$(find "$album_dir" -type d -exec find {} -maxdepth 1 -type f \
    -iregex ".*/.*\(${album}\|cover\|folder\|artwork\|front\).*[.]\\(jpe?g\|png\|gif\|bmp\)" \; )"
    cover_path="$(echo "$found_covers" | head -n1)"
    if [ -n "$cover_path" ]; then
        return
    fi

    # If we still failed to find a cover image, we use the fallback
    if [ -z "$cover_path" ]; then
        cover_path=$fallback_image
    fi
}

display_cover_image() {
    compute_geometry
    kitty +kitten icat --align left --place "${width}x${height}@${left}x${padding_top}" "$cover_path"
}

detect_window_resizes() {
    {
        trap 'display_cover_image' WINCH
        while :; do sleep .1; done
    } &
}


# ==== Helper functions =========================================================

compute_geometry() {
    unset LINES COLUMNS # Required in order for tput to work in a script
    term_lines=$(tput lines)
    term_cols=$(tput cols)
    if [ -z "$font_height" ] || [ -z "$font_height" ]; then
        guess_font_size
    fi

    height=$(( term_lines - padding_top - padding_bottom ))
    width=$(( height * font_height / font_width ))
    left=$(( term_cols - width - padding_right ))

        compute_geometry_aligned

    apply_force_square_setting
}

compute_geometry_aligned() {
    left=$padding_left
    max_width_chars=$(( term_cols * max_width / 100 ))
    if [ "$max_width" != 0 ] &&
        [ $(( width + padding_right + padding_left )) -gt "$max_width_chars" ]; then
        width=$(( max_width_chars - padding_left - padding_right ))
    fi
}

apply_force_square_setting() {
    if [ $force_square = "true" ]; then
        height=$(( width * font_width / font_height ))
        padding_top=$(( term_lines - padding_bottom - height ))
    fi
}

guess_font_size() {
    guess_terminal_pixelsize

    approx_font_width=$(( term_width / term_cols ))
    approx_font_height=$(( term_height / term_lines ))

    term_xpadding=$(( ( - approx_font_width * term_cols + term_width ) / 2 ))
    term_ypadding=$(( ( - approx_font_height * term_lines + term_height ) / 2 ))

    font_width=$(( (term_width - 2 * term_xpadding) / term_cols ))
    font_height=$(( (term_height - 2 * term_ypadding) / term_lines ))
}

guess_terminal_pixelsize() {
    python <<END
import sys, struct, fcntl, termios

def get_geometry():
    fd_pty = sys.stdout.fileno()
    farg = struct.pack("HHHH", 0, 0, 0, 0)
    fretint = fcntl.ioctl(fd_pty, termios.TIOCGWINSZ, farg)
    rows, cols, xpixels, ypixels = struct.unpack("HHHH", fretint)
    return "{} {}".format(xpixels, ypixels)

output = get_geometry()
f = open("/tmp/ncmpcpp_geometry.txt", "w")
f.write(output)
f.close()
END

    # ioctl doesn't work inside $() for some reason so we
    # must use a temporary file
    term_width=$(awk '{print $1}' /tmp/ncmpcpp_geometry.txt)
    term_height=$(awk '{print $2}' /tmp/ncmpcpp_geometry.txt)
    rm "/tmp/ncmpcpp_geometry.txt"

    if ! is_font_size_successfully_computed; then
        echo "Failed to guess font size, try setting it in cover_art.sh settings"
    fi
}

is_font_size_successfully_computed() {
    [ -n "$term_height" ] && [ -n "$term_width" ] &&
        [ "$term_height" != "0" ] && [ "$term_width" != "0" ]
}


calc() {
    awk "BEGIN{print $*}"
}

main
