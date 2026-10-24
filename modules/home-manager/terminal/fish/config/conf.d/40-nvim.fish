# Optional integration: importing Fish alone must not assume an editor or finder.
if command -q nvim
    abbr -a e nvim
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
    if command -q fd
        function nvim-config --description 'Choose an editable Neovim source file'
            if not set -q DOTFILES_NVIM_SOURCE; or not test -d "$DOTFILES_NVIM_SOURCE"
                echo 'Set DOTFILES_NVIM_SOURCE to the Neovim source directory in your checkout.' >&2
                return 1
            end
            set -l file (fd --type f --follow . "$DOTFILES_NVIM_SOURCE" | fzf --reverse --height 80% --border)
            test -n "$file"; or return 1
            nvim "$file"
        end
        abbr -a nvimc nvim-config
    end
end
