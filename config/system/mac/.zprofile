# ~/.zprofile — macOS zsh login. Homebrew PATH + SSH agent socket.

# Homebrew (Apple Silicon first, then Intel)
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) export PATH="$HOME/.local/bin:$PATH" ;;
esac

# Shared POSIX login config (editor/pager/secrets)
[ -r "$HOME/.profile" ] && . "$HOME/.profile"
