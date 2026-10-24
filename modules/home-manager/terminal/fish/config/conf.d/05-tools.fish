# Only configure tools and native resources that actually exist. Fish remains
# useful when imported alone, and never overwrites an inherited editor choice.
if not set -q EDITOR
    if command -q nvim
        set -gx EDITOR nvim
    else if command -q vim
        set -gx EDITOR vim
    else
        set -gx EDITOR vi
    end
end
set -q VISUAL; or set -gx VISUAL "$EDITOR"
if command -q less
    set -gx PAGER less
    set -gx LESS '-R -F -X'
end
command -q nvim; and set -gx MANPAGER 'nvim +Man!'
set -l config_home "$HOME/.config"
set -q XDG_CONFIG_HOME; and set config_home "$XDG_CONFIG_HOME"
if test -r "$config_home/vale/.vale.ini"
    set -gx VALE_CONFIG_PATH "$config_home/vale/.vale.ini"
end
if command -q rg; and test -r "$config_home/ripgrep/ripgreprc"
    set -gx RIPGREP_CONFIG_PATH "$config_home/ripgrep/ripgreprc"
end
if command -q bat; and test -r "$config_home/bat/themes/dotfiles.tmTheme"
    set -gx BAT_THEME dotfiles
end
if command -q fzf
    set -gx FZF_DEFAULT_OPTS '--height=40% --layout=reverse --border'
    if test -r "$config_home/fzf/theme.opts"
        set -gx FZF_DEFAULT_OPTS "$FZF_DEFAULT_OPTS "(string join ' ' < "$config_home/fzf/theme.opts")
    end
    if command -q fd
        set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
        set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
        set -gx FZF_ALT_C_COMMAND 'fd --type d --hidden --follow --exclude .git'
    end
end
