status is-interactive; or return

# Optional integration: importing Fish alone must not assume an editor or finder.
if command -q nvim
    abbr -a e nvim
    function nvim-config --description 'Edit canonical Neovim configuration sources'
        nvim +DotfilesConfig $argv
    end
    abbr -a nvimc nvim-config
else if command -q vim
    abbr -a e vim
end
if command -q nvim; and command -q fzf
    function nvim-fzf --description 'Choose a file and open it in Neovim'
        set -l preview 'cat -- {}'
        command -q bat; and set preview 'bat --style=numbers --color=always --line-range :500 {}'
        set -l file (fzf --reverse --height 80% --border --preview "$preview")
        test -n "$file"; or return 1
        nvim "$file"
    end
    abbr -a f nvim-fzf
end
