# ── Editor / Pager ─────────────────────────────────────
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx PAGER less
set -gx LESS "-R -F -X"
set -gx MANPAGER "nvim +Man!"

# --- Tooling ----------------------------------------------
set -gx VALE_CONFIG_PATH $HOME/.config/vale/.vale.ini

# ── Common CLI behavior ────────────────────────────────
set -gx RIPGREP_CONFIG_PATH "$HOME/.config/ripgrep/ripgreprc"
set -gx FZF_DEFAULT_OPTS "--height=40% --layout=reverse --border"

# wana: apply active variant to bat + fzf
set -l _wana_variant dark
test -r "$HOME/.cache/wana/variant"; and set _wana_variant (cat "$HOME/.cache/wana/variant")
set -gx BAT_THEME "wana-$_wana_variant"

set -l _wana_fzf "$HOME/.config/fzf/wana-$_wana_variant.opts"
test -r "$_wana_fzf"; and set -gx FZF_DEFAULT_OPTS "$FZF_DEFAULT_OPTS "(cat "$_wana_fzf")
set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
set -gx FZF_CTRL_T_COMMAND  $FZF_DEFAULT_COMMAND
set -gx FZF_ALT_C_COMMAND   'fd --type d --hidden --follow --exclude .git'
