#!/bin/sh
# Convenience shim — forwards to script/setup.sh
SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
exec "${SCRIPT_DIR}/script/setup.sh" "$@"
