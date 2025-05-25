# basic
abbr c clear
abbr cls clear
abbr se sudoedit

# trash
abbr rmm "rm -rv"
abbr rm "gio trash"
abbr trl "gio trash --list"
abbr trm "gio trash"
abbr trs "gio trash --restore"

# Source: https://www.baeldung.com/linux/delete-empty-files-dirs
abbr rm-empty-files "find . -type f -empty -print -delete"
abbr rm-empty-folders "find . -type d -empty -print -delete"

# exa/eza
abbr ll "eza --icons --group-directories-first -lgh"
abbr lla "eza --icons --group-directories-first -algh"
abbr ls "eza --icons --group-directories-first"
abbr lsa "eza --icons --group-directories-first -a"
abbr lt "eza --icons --group-directories-first -T"
abbr tree "eza --icons --group-directories-first -T"

# neofetch
abbr f "neofetch --config none"
abbr fetch "neofetch --config none"

# fzf
abbr fzfp "fzf --reverse --preview 'bat --style=numbers --color=always --line-range :500 {}'"

# git {{{
abbr g git
abbr ga "git add"
abbr gcl "git clone --depth 1"
abbr gcm "git commit -m"
abbr gco "git checkout"
abbr gcb "git checkout -b"
abbr gl "git pull"
abbr gp "git push"
abbr gs "git status"

abbr lg "lazygit"
# }}}

# systemctl {{{
abbr scr "sudo systemctl restart"
abbr sce "sudo systemctl enable"
abbr scd "sudo systemctl disable"
abbr scs "sudo systemctl status"
abbr scss "sudo systemctl star"
abbr scsss "sudo systemctl stop"

abbr scru "systemctl --user restart"
abbr sceu "systemctl --user enable"
abbr scdu "systemctl --user disable"
abbr scsu "systemctl --user status"
abbr scssu "systemctl --user star"
abbr scsssu "systemctl --user stop"
# }}}
