# ~/.zshrc — macOS interactive zsh: hand off to fish when available.
# Parent check strips the path (BSD ps reports full path) to detect fish.
if command -v fish >/dev/null 2>&1 && [[ $- == *i* ]]; then
  _parent="$(ps -o comm= -p $PPID 2>/dev/null)"
  case "${_parent##*/}" in
    fish | -fish) ;;
    *) exec fish ;;
  esac
  unset _parent
fi
