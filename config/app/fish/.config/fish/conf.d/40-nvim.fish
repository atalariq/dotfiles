set -g NVIM_PROFILES \
    nvim \
    nvim-minimal \
    nvim-minimax

if not set -q NVIM_APPNAME
    set -Ux NVIM_APPNAME nvim
end

function nvim-default-select --description "Select and set global default NVIM_APPNAME"
    set -l appname (
        printf "%s\n" $NVIM_PROFILES | fzf --prompt "Set default NVIM_APPNAME> "
    )

    test -n "$appname"; or return 1

    set -Ux NVIM_APPNAME $appname

    echo "Default NVIM_APPNAME set to: $appname"
end

# ------------------------------------------------------------
# Neovim + fzf file picker
# ------------------------------------------------------------
function nvim-fzf --description "Pick a file with fzf and open it in Neovim"
    set -l file (
        fzf \
            --reverse \
            --height 80% \
            --border \
            --preview 'bat --style=numbers --color=always --line-range :500 {}' \
            --preview-window 'right:60%:wrap'
    )

    test -n "$file"; or return 1

    nvim "$file"
end

# ------------------------------------------------------------
# Neovim + fzf config picker
# ------------------------------------------------------------
function nvim-config --description "Pick a nvim configurations file with fzf and open it in Neovim"
    set -l file (
        fd --type f --follow . "$XDG_CONFIG_HOME/$NVIM_APPNAME" | \
        fzf \
            --reverse \
            --height 80% \
            --border \
            --preview 'bat --style=numbers --color=always --line-range :500 {}' \
            --preview-window 'right:60%:wrap'
    )

    test -n "$file"; or return 1

    nvim "$file"
end

# ------------------------------------------------------------
# Abbreviations & Aliases
# ------------------------------------------------------------

abbr -a e nvim
abbr -a f nvim-fzf
abbr -a nvimc nvim-config
abbr -a nvds nvim-default-select

alias nvimd "env NVIM_APPNAME=nvim nvim"
alias nvimm "env NVIM_APPNAME=nvim-minimal nvim"
alias nvimx "env NVIM_APPNAME=nvim-minimax nvim"
