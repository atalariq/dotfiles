#!/usr/bin/env sh
# Retired compatibility entrypoint. Never decrypt into a login shell.
# Runtime secrets are owned by the per-application sops-nix wrappers.
printf '%s\n' 'secrets/load.sh is retired. Use <application>-with-secrets command [arguments...].' \
	'Provision the age identity under XDG_CONFIG_HOME/sops/age/keys.txt (default ~/.config/sops/age/keys.txt), or configure dotfiles.services.secrets.keyFile.' >&2
# The subshell keeps sourcing safe: no exit or environment mutation in the caller.
(exit 2)
