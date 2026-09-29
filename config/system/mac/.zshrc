# # Launch fish if interactive and not already inside fish
if [[ -o interactive && -z "$FISH_VERSION" ]]; then
  exec fish
fi

# Lerd completions
fpath=(/Users/atalariq/.local/share/zsh/site-functions $fpath)
autoload -Uz compinit && compinit

# Lerd
export PATH="/Users/atalariq/.local/share/lerd/bin:$PATH"
