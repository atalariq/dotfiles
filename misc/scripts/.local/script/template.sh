#!/usr/bin/env bash
set -euo pipefail

# ─── version ─────────────────────────────────────────────────────────────────
readonly VERSION="0.1.0"

# ─── logging ─────────────────────────────────────────────────────────────────
info() { echo -e "\033[0;36m→\033[0m $*"; }
ok() { echo -e "  \033[0;32m✓\033[0m $*"; }
warn() { echo -e "\033[1;33mwarn:\033[0m $*" >&2; }
err() { echo -e "\033[0;31merror:\033[0m $*" >&2; }

# ─── usage ───────────────────────────────────────────────────────────────────
readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
usage() {
  cat <<EOF
${SCRIPT_NAME} — short description

Usage:
  ${SCRIPT_NAME} [options] <required-arg>

Options:
  -h, --help      Show this help
  -v, --version   Show version

Examples:
  ${SCRIPT_NAME} example
EOF
  exit "${1:-0}"
}

# ─── cleanup ─────────────────────────────────────────────────────────────────
cleanup() {
  # Remove temp files, kill background processes, etc.
  :
}
trap cleanup EXIT INT TERM

# ─── argument parsing ────────────────────────────────────────────────────────
parse_args() {
  while [[ ${#} -gt 0 ]]; do
    case "${1}" in
    -h | --help) usage 0 ;;
    -v | --version)
      echo "${VERSION}"
      exit 0
      ;;
    --)
      shift
      break
      ;;
    -*)
      err "Unknown option: ${1}"
      usage 1
      ;;
    *) break ;;
    esac
    shift
  done
}

# ─── main ────────────────────────────────────────────────────────────────────
main() {
  parse_args "$@"

  info "Starting ${SCRIPT_NAME}..."

  # Your logic here

  ok "Done."
}

main "$@"
