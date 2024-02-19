function fish-reload --description "Reload fish configurations"
    set CONFIG_DIR $HOME/.config/fish
    source $CONFIG_DIR/config.fish
    source $CONFIG_DIR/conf.d/*.fish
    source $CONFIG_DIR/functions/*.fish
end
