# Exit Vim-Like
alias :Q exit
alias :q exit

alias .. "cd .."
alias ... "cd ../.."
alias .... "cd ../../.."
alias ..... "cd ../../../.."

alias c clear
alias h history
alias j "jobs -l"

alias grep "grep --color auto"
alias egrep "egrep --color auto"
alias fgrep "fgrep --color auto"

alias mkdir "mkdir -pv"
alias mount "mount |column -t"

alias mv "mv -i"
alias cp "cp -i"
alias ln "ln -i"

alias chown "chown --preserve-root"
alias chmod "chmod --preserve-root"
alias chgrp "chgrp --preserve-root"

alias root "sudo -i"
alias su "sudo -i"

alias df "df -h"
alias du "du -ch"
alias free "free -m"
alias top "htop"

alias cat bat

# exa/eza
alias ll "eza --icons --group-directories-first -lgh"
alias lla "eza --icons --group-directories-first -algh"
alias ls "eza --icons --group-directories-first"
alias lsa "eza --icons --group-directories-first -a"
alias lt "eza --icons --group-directories-first -T"
alias tree "eza --icons --group-directories-first -T"

# browser
alias brave /opt/brave-bin/brave-browser
alias chrome /opt/google/chrome/google-chrome
alias browser brave
