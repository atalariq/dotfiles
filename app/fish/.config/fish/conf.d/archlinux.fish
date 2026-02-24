# Check if using Arch-Based or Not
command -q pacman || return 1

# Set Super User Command e.g. sudo | doas
command -q doas && set PERMISSION_CMD doas || set PERMISSION_CMD sudo

# Set AUR Helper
command -q paru && set AUR_HELPER paru
command -q yay && set AUR_HELPER yay

if command -v $AUR_HELPER >/dev/null
    abbr pmu "$AUR_HELPER -Syu"
    abbr pmi "$AUR_HELPER -S"
    abbr pms "$AUR_HELPER -Ss"

    abbr ppmu "$PERMISSION_CMD pacman -Syu"
    abbr ppmi "$PERMISSION_CMD pacman -S"
    abbr ppms "pacman -Ss"
else
    abbr pmu "$PERMISSION_CMD pacman -Syu"
    abbr pmi "$PERMISSION_CMD pacman -S"
    abbr pms "pacman -Ss"
end

abbr pmq "pacman -Qi"
abbr pmr "$PERMISSION_CMD pacman -Rns"
abbr pmro "pacman -Qtdq | $PERMISSION_CMD pacman -Rns -"
