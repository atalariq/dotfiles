function nvim-fzf --description "nvim + fzf for file picker"
    nvim $(fzf --reverse --preview 'bat --style=numbers --color=always --line-range :500 {}')
end
