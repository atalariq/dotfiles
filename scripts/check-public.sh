# Public repository guard.
#
# This repo must never contain private inventory. The check runs in CI and from
# the pre-commit hook; it fails closed, so an accidental copy of a private host
# or secret path stops the commit.
set -euo pipefail

fail=0

deny_paths=(
  "secrets"
  ".sops.yaml"
  "hosts/nixos/clairvoyant"
  "hosts/nixos/sibyl"
  "hosts/nixos/thinkpad-x13"
  "hosts/darwin/macmini-lab"
  ".beads"
  "loadtest/citra.js"
  "docs/clairvoyant.md"
  "docs/homelab.md"
)

for path in "${deny_paths[@]}"; do
  if [ -e "$path" ]; then
    printf 'private path present: %s\n' "$path" >&2
    fail=1
  fi
done

deny_strings=(
  "clairvoyant"
  "cp-api.atalariq.dev"
  "caddy_dns_token"
  "100.64.0.1"
  "168.110.216.85"
  "deploy_comprehensive_rust"
)

for string in "${deny_strings[@]}"; do
  if git grep -n -I -e "$string" -- . ':(exclude)scripts/check-public.sh' >/dev/null 2>&1; then
    printf 'private string present: %s\n' "$string" >&2
    fail=1
  fi
done

if [ "$fail" -ne 0 ]; then
  printf '\npublic guard failed; do not commit private inventory here\n' >&2
  exit 1
fi

printf 'public guard: ok\n'
