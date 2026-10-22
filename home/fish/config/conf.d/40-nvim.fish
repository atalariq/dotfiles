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
        fd --type f --follow . "$XDG_CONFIG_HOME/nvim" | \
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

if command -q nvim
    abbr -a e nvim
else
    abbr -a e vim
end
abbr -a f nvim-fzf
abbr -a nvimc nvim-config
