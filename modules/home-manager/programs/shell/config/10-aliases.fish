status is-interactive; or return

# Exit Vim-Like
alias :Q exit
alias :q exit

# alias cd='pushd'
# alias pd='popd'

# alias .. "cd .."
# alias ... "cd ../.."
# alias .... "cd ../../.."
# alias ..... "cd ../../../.."

alias c clear
alias h history
alias j "jobs -l"

alias df "df -h"
alias du "du -ch"
alias free "free -m"
command -q btop; and alias top btop

# ── Safer defaults ─────────────────────────────────────
alias cp "cp -iv"
alias mv "mv -iv"
if test (uname) = Linux
    alias rm "rm -Iv"
else
    alias rm "rm -iv"
end
alias mkdir "mkdir -pv"

if test (uname) = Linux
    alias chown "chown --preserve-root"
    alias chmod "chmod --preserve-root"
    alias chgrp "chgrp --preserve-root"
end

alias root "sudo -i"
alias su "sudo -i"

# ── Modern replacements ────────────────────────────────
# ls/ll/… live in programs.fish.shellAliases (must beat /etc/fish/config.fish).

command -q bat; and alias cat "bat --paging=never"
