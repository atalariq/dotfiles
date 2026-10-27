status is-interactive; or return

# Check if using Arch-Based or Not
command -q pacman || return 1

# Set Super User Command e.g. sudo | doas
set -l permission_cmd sudo
command -q doas; and set permission_cmd doas

# Set AUR Helper
set -l aur_helper
command -q paru; and set aur_helper paru
command -q yay; and set aur_helper yay

if test -n "$aur_helper"
    abbr pmu "$aur_helper -Syu"
    abbr pmi "$aur_helper -S"
    abbr pms "$aur_helper -Ss"

    abbr ppmu "$permission_cmd pacman -Syu"
    abbr ppmi "$permission_cmd pacman -S"
    abbr ppms "pacman -Ss"
else
    abbr pmu "$permission_cmd pacman -Syu"
    abbr pmi "$permission_cmd pacman -S"
    abbr pms "pacman -Ss"
end

abbr pmq "pacman -Qi"
abbr pmr "$permission_cmd pacman -Rns"
abbr pmro "pacman -Qtdq | $permission_cmd pacman -Rns -"
