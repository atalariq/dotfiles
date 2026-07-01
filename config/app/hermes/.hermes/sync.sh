#!/usr/bin/env bash
# Sync Hermes configs between ~/.hermes/ and this dotfiles directory.
#
# Usage:
#   ./sync.sh push    # Copy from ~/.hermes/ → dotfiles (backup)
#   ./sync.sh pull    # Copy from dotfiles → ~/.hermes/ (restore)
#   ./sync.sh link    # Symlink ~/.hermes/* → dotfiles (live sync)
#
# NOTE: .env and auth.json contain secrets — NEVER check them in.
# - API keys go in ~/.hermes/.env (already in .gitignore)
# - OAuth tokens go in ~/.hermes/auth.json (ephemeral/session-based)

set -euo pipefail

HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

case "${1:-help}" in
  push)
    echo "→ Backing up Hermes configs to dotfiles..."
    cp "$HERMES_HOME/config.yaml" "$DOTFILES_DIR/config.yaml"
    for p in researcher reviewer writer fixer; do
      [ -f "$HERMES_HOME/profiles/$p/config.yaml" ] && \
        cp "$HERMES_HOME/profiles/$p/config.yaml" "$DOTFILES_DIR/profiles/$p.yaml"
    done
    [ -f "$HERMES_HOME/SOUL.md" ] && cp "$HERMES_HOME/SOUL.md" "$DOTFILES_DIR/SOUL.md"
    echo "✅  Done. Review with 'git diff' before committing."
    ;;

  pull)
    echo "→ Restoring Hermes configs from dotfiles..."
    cp "$DOTFILES_DIR/config.yaml" "$HERMES_HOME/config.yaml"
    for f in "$DOTFILES_DIR"/profiles/*.yaml; do
      pname="$(basename "$f" .yaml)"
      mkdir -p "$HERMES_HOME/profiles/$pname"
      cp "$f" "$HERMES_HOME/profiles/$pname/config.yaml"
    done
    [ -f "$DOTFILES_DIR/SOUL.md" ] && cp "$DOTFILES_DIR/SOUL.md" "$HERMES_HOME/SOUL.md"
    echo "✅  Restored. Restart Hermes for changes to take effect."
    ;;

  link)
    echo "→ Symlinking ~/.hermes/config.yaml → dotfiles..."
    ln -sf "$DOTFILES_DIR/config.yaml" "$HERMES_HOME/config.yaml"
    for f in "$DOTFILES_DIR"/profiles/*.yaml; do
      pname="$(basename "$f" .yaml)"
      mkdir -p "$HERMES_HOME/profiles/$pname"
      ln -sf "$f" "$HERMES_HOME/profiles/$pname/config.yaml"
    done
    [ -f "$DOTFILES_DIR/SOUL.md" ] && ln -sf "$DOTFILES_DIR/SOUL.md" "$HERMES_HOME/SOUL.md"
    echo "✅  Symlinked. Hermes writes will be tracked in git."
    echo "⚠️  After 'hermes setup' or updates, run 'sync.sh push' to capture new keys."
    ;;

  *)
    echo "Hermes dotfiles sync — Usage: $0 {push|pull|link}"
    echo ""
    echo "  push   backup: ~/.hermes/ → dotfiles"
    echo "  pull   restore: dotfiles → ~/.hermes/"
    echo "  link   symlink: ~/.hermes/ --> dotfiles (live tracking)"
    exit 1
    ;;
esac
