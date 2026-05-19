function reload --description "Reload Fish configuration"
    # Sourcing the main config file is usually enough,
    # as it typically handles sourcing other snippets.
    if test -f ~/.config/fish/config.fish
        source ~/.config/fish/config.fish
        echo "Source: ~/.config/fish/config.fish"
    end

    # Optional: If you want to force-reload all functions explicitly
    for f in ~/.config/fish/conf.d/*.fish; source $f; end
    for f in ~/.config/fish/functions/*.fish; source $f; end
    for f in ~/.config/fish/completions/*.fish; source $f; end

    set_color green
    echo "󰈐 Fish configuration reloaded!"
    set_color normal
end
