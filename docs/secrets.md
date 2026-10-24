# Secrets and authentication

## Provision identities

Encrypted SOPS data can be committed; private identities cannot. Substitute your
own encrypted source and recipients when adapting this configuration. Provision
the user's age identity at `~/.config/sops/age/keys.txt`, mode 0600 in a private
directory, or set `dotfiles.security.secrets.keyFile` to its existing location.
Do not create an unrelated identity and assume it can decrypt existing data.

System services use the NixOS module's separately provisioned identity at
`/var/lib/sops-nix/key.txt`. No system secret is declared merely by enabling
support. Add declarations alongside the actual service that consumes them.

Back up recovery identities offline or in your established password manager.
Verify recovery against a copy of encrypted data before rotating recipients.
Use SOPS to update recipients; do not expose plaintext through Nix expressions,
command arguments, terminal output or Git.

## Declare an application

```nix
{
  dotfiles.security.secrets.enable = true;
  dotfiles.security.secrets.applications.example = {
    API_KEY = "SOPS_KEY_NAME";
  };
}
```

This creates `example-with-secrets command [arguments...]`. The wrapper reads only
the runtime files named by the application mapping and exports them to its child
process. It fails before launching if a required secret file is unavailable.
Values never enter the generated script or Nix store.

After provisioning, start/check the user service:

```sh
systemctl --user start sops-nix.service
systemctl --user status sops-nix.service
hermes-with-secrets hermes
```

Hermes' mapping uses its dedicated DeepSeek key and its configured provider/tool
keys. The CLI is installed from the pinned llm-agents input; gateway/background
execution is not enabled. Memories, sessions and credentials remain writable in
user state. Change managed Hermes settings in source and rebuild (or edit them in live
mode). Keep API keys in the runtime secret mapping, outside native settings.

## SSH and GnuPG

One OpenSSH agent owns SSH credentials. Fish preserves an inherited socket,
including agent forwarding, and uses the system user-agent socket only when no
socket was inherited. Do not start a second agent per terminal.

GnuPG runs separately with graphical pinentry. The Git configuration supports SSH
signing through a user-local include; key selection, signing requirements and
credentials remain local. Do not force a new signing identity during a layout
change. On a server, select terminal pinentry if graphical pinentry is unavailable.
