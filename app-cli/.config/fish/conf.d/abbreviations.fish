# abbreviations.fish

# base
abbr c clear
abbr cls clear
abbr se sudoedit

# trash
abbr rmm rm
abbr rm "gio trash"
abbr trl "gio trash --list"
abbr trm "gio trash"
abbr trs "gio trash --restore"

# exa/eza
abbr ll "exa --icons --group-directories-first -lgh"
abbr lla "exa --icons --group-directories-first -algh"
abbr ls "exa --icons --group-directories-first"
abbr lsa "exa --icons --group-directories-first -a"
abbr lt "exa --icons --group-directories-first -T"
abbr tree "exa --icons --group-directories-first -T"

# neofetch
abbr fetch "neofetch --config none"

# fzf/skim
abbr fzfp "fzf --reverse --preview 'bat --style=numbers --color=always --line-range :500 {}'"

# ============== file manager {{{

### nnn
# abbr n nnncd
# abbr fm nnn

### yazi
abbr y yazi
abbr fm yazi

# }}}

# git {{{
abbr g git
abbr ga "git add"
abbr gb "git branch"
abbr gc "git config"
abbr gcl "git clone --depth 1"
abbr gcm "git commit -m"
abbr gco "git checkout"
abbr gcb "git checkout -b"
abbr gl "git pull"
abbr gp "git push"
abbr gr "git remove"
abbr gs "git status"

abbr lg lazygit
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
