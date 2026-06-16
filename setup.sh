#!/usr/bin/env bash
# Convenience shim — forwards to script/setup.sh
exec "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/script/setup.sh" "$@"
