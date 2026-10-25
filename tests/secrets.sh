#!/usr/bin/env bash
# shellcheck disable=SC2016 # Child-shell programs and hostile test values stay literal.
# The retired loader must never decrypt, evaluate a value, or mutate its caller.
set -euo pipefail
loader=$1
wrapper=$2
work=$(mktemp -d)
trap 'rm -rf -- "$work"' EXIT
mkdir "$work/bin"
cat >"$work/bin/sops" <<'SH'
#!/bin/sh
touch "$SECRET_TEST_WORK/decrypted"
printf 'INJECTED=$(touch "%s/injected")\n' "$SECRET_TEST_WORK"
SH
chmod +x "$work/bin/sops"
export SECRET_TEST_WORK=$work PATH="$work/bin:$PATH" SECRETS_FILE="$work/secrets.yaml"
printf encrypted >"$SECRETS_FILE"
unset SOPS_AGE_KEY_FILE INJECTED
if sh "$loader"; then
	echo 'Retired loader succeeded' >&2
	exit 1
fi
# shellcheck disable=SC1090 # The source path is the explicitly supplied test subject.
if . "$loader"; then
	echo 'Sourced retired loader succeeded' >&2
	exit 1
fi
test ! -e "$work/decrypted"
test ! -e "$work/injected"
test "${SOPS_AGE_KEY_FILE+set}" = ''
test "${INJECTED+set}" = ''
printf 'Retired secrets loader refuses decryption and leaves caller unchanged.\n'

# A readable path can still fail at read time; never launch with an empty token.
secret_dir=/tmp/dotfiles-secret-test
mkdir -p "$secret_dir"
if "$wrapper" sh -c 'touch "$SECRET_TEST_WORK/launched"'; then exit 1; fi
test ! -e "$work/launched"
mkdir "$secret_dir/token"
if "$wrapper" sh -c 'touch "$SECRET_TEST_WORK/launched"'; then exit 1; fi
test ! -e "$work/launched"
rmdir "$secret_dir/token"
# Literal shell syntax and embedded newlines remain data in the child.
printf '%s\n%s' '$(touch injected)' 'second line' >"$secret_dir/token"
"$wrapper" sh -c 'printf %s "$API_TOKEN" >"$SECRET_TEST_WORK/token"'
cmp "$secret_dir/token" "$work/token"
test ! -e injected
printf 'Secret wrapper: unavailable/read failure stops launch; multiline values stay literal.\n'
