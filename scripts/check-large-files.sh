#!/usr/bin/env bash
# Reject oversized blobs in the tree being pushed. This intentionally checks the
# current HEAD tree rather than all history: the history rewrite is the one-time
# cleanup, while this guard keeps new large files out of future commits.
set -euo pipefail

limit_bytes="${LARGE_FILE_LIMIT:-1048576}"

# Paths that are deliberately allowed above the limit.
allow_regex='^modules/home-manager/programs/gui/config/mpv/fonts/.*\.ttf$|^flake\.lock$'

fail=0
while IFS= read -r -d '' entry; do
  meta="${entry%%$'\t'*}"
  path="${entry#*$'\t'}"
  read -r _mode type _object size <<<"$meta"
  [ "$type" = "blob" ] || continue
  [ "$size" -gt "$limit_bytes" ] || continue

  if [[ "$path" =~ $allow_regex ]]; then
    continue
  fi

  printf 'large file: %s (%s bytes)\n' "$path" "$size" >&2
  fail=1
done < <(git ls-tree -r -l -z HEAD)

if [ "$fail" -ne 0 ]; then
  printf '\nBlocked: tracked files exceed %s bytes. Add an allowlist entry only for intentional assets.\n' "$limit_bytes" >&2
  exit 1
fi
