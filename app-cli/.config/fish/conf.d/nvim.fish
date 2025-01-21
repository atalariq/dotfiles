set -gx NVIM_APPNAME $(cat ~/.cache/nvim-default-profile)

# --------------------------------------------------------------------------------------
set items $(ls ~/.config | grep nvim)

# --------------------------------------------------------------------------------------
function nvim-switcher
    set config (printf "%s\n" $items | fzf --prompt=" Pick Neovim Config: " --height=~50% --layout=reverse --border --exit-0)
    if [ -z $config ]
        echo "Nothing selected"
        return
    else if [ $config = default ]
        set config nvim
    end
    NVIM_APPNAME=$config nvim $argv
end

# --------------------------------------------------------------------------------------
function nvim-set-default
    set config (printf "%s\n" $items | fzf --prompt=" Set DefaultNeovim `\$NVIM_APPNAME` : " --height=~50% --layout=reverse --border --exit-0)
    if [ -z $config ]
        echo "Nothing selected"
        return
    else if [ $config = default ]
        set config nvim
    end
    set -gx NVIM_APPNAME $config
    echo "\$NVIM_APPNAME is set to `$config`"
    echo "$config" >~/.cache/nvim-default-profile
end

# --------------------------------------------------------------------------------------

function nvim-fzf
    set file (fzf --reverse --preview 'bat --style=numbers --color=always --line-range :500 {}')

    if [ -z $file ]
        echo "Nothing selected"
        return
    end
    nvim "$file"
end

# --------------------------------------------------------------------------------------
abbr e "NVIM_APPNAME=$NVIM_APPNAME nvim"
abbr ns nvim-switcher
abbr nsd nvim-set-default
abbr nf nvim-fzf
abbr ef nvim-fzf
