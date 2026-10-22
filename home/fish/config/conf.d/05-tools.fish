# ── Editor / Pager ─────────────────────────────────────
if command -q nvim
    set -gx EDITOR nvim
else if command -q vim
    set -gx EDITOR vim
else
    set -gx EDITOR vi
end
set -gx VISUAL "$EDITOR"
set -gx PAGER less
set -gx LESS "-R -F -X"
command -q nvim; and set -gx MANPAGER "nvim +Man!"

# --- Tooling ----------------------------------------------
set -gx VALE_CONFIG_PATH $__fish_config_dir/../vale/.vale.ini

# ── Common CLI behavior ────────────────────────────────
set -gx RIPGREP_CONFIG_PATH "$__fish_config_dir/../ripgrep/ripgreprc"
set -gx FZF_DEFAULT_OPTS "--height=40% --layout=reverse --border"

set -gx BAT_THEME dotfiles
set -l fzf_theme "$XDG_CONFIG_HOME/fzf/theme.opts"
test -r "$fzf_theme"; and set -gx FZF_DEFAULT_OPTS "$FZF_DEFAULT_OPTS "(string join ' ' < "$fzf_theme")
set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
set -gx FZF_CTRL_T_COMMAND  $FZF_DEFAULT_COMMAND
set -gx FZF_ALT_C_COMMAND   'fd --type d --hidden --follow --exclude .git'
