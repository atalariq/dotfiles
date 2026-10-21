# This folder is usable on its own at $XDG_CONFIG_HOME/fish.
if status is-interactive
    if type -q starship
        starship init fish | source
    end
    if type -q zoxide
        zoxide init fish | source
    end
    if type -q direnv
        direnv hook fish | source
    end
end

# Machine-specific preferences always run after the shared defaults.
if test -f $__fish_config_dir/config.local.fish
    source $__fish_config_dir/config.local.fish
end
