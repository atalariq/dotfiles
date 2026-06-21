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
alias top "htop"

# ── Safer defaults ─────────────────────────────────────
alias cp "cp -iv"
alias mv "mv -iv"
alias rm "rm -Iv"
alias mkdir "mkdir -pv"

alias chown "chown --preserve-root"
alias chmod "chmod --preserve-root"
alias chgrp "chgrp --preserve-root"

alias root "sudo -i"
alias su "sudo -i"

# ── Modern replacements ────────────────────────────────
if command -q eza
    alias ll "eza --icons --group-directories-first -lgh"
    alias lla "eza --icons --group-directories-first -algh"
    alias ls "eza --icons --group-directories-first"
    alias lsa "eza --icons --group-directories-first -a"
    alias lt "eza --icons --group-directories-first -T"
    alias tree "eza --icons --group-directories-first -T"
else
    alias ll "ls -lah"
    alias la "ls -A"
end

if command -q bat
    alias cat "bat --paging=never"
end

# browser
alias brave /opt/brave-bin/brave-browser
alias chrome /opt/google/chrome/google-chrome
alias browser brave

alias drop "ripdrag --and-exit --basename --no-click --resizable --all"
alias drag "ripdrag --basename --resizable --all --target"
