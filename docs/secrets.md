# Secrets Management

Dotfiles uses [SOPS](https://github.com/getsops/sops) with [age](https://github.com/FiloSottile/age) encryption to manage secrets.

## Setup

### 1. Generate an age key

```sh
mkdir -p ~/.config/age
age-keygen -o ~/.config/age/keys.txt
```

Your public key is printed to stdout. Copy it.

### 2. Configure `.sops.yaml`

Update `.sops.yaml` at the repo root with your public key:

```yaml
creation_rules:
  - path_regex: .*secrets\.yaml$
    age: <your-public-age-key>
```

### 3. Create `secrets.yaml`

```sh
sops secrets/secrets.yaml
```

SOPS opens your editor. Add entries in dotenv format:

```dotenv
GITHUB_TOKEN=***
OPENAI_API_KEY=***
ANTHROPIC_API_KEY=sk-ant...xxxx
```

Save and close. SOPS encrypts the file automatically.

### 4. Verify decryption

```sh
sops -d secrets/secrets.yaml
```

Should print your keys in `KEY=VALUE` format.

## File Locations

| Repo path                                             | Deployed to                             | Role                       |
| ----------------------------------------------------- | --------------------------------------- | -------------------------- |
| `secrets/secrets.yaml`                                | `~/.config/sops/secrets.yaml`           | Encrypted secrets store    |
| `secrets/load.sh`                                     | `~/.local/script/secrets-load`          | POSIX loader (bash/zsh/sh) |
| `config/app/fish/.config/fish/conf.d/90-secrets.fish` | `~/.config/fish/conf.d/90-secrets.fish` | Fish thin wrapper          |
| `config/system/archlinux/.profile`                    | `~/.profile`                            | Sources loader at login    |
| `.sops.yaml`                                          | repo root                               | SOPS encryption rules      |
| `~/.config/age/keys.txt`                              | never committed                         | Age private key            |

## How It Works

```
.profile → ~/.local/script/secrets-load → sops -d secrets.yaml → export KEY=VALUE
fish     → conf.d/90-secrets.fish → bash → secrets-load → re-export into fish env
```

## Key Rotation

1. Generate a new key: `age-keygen -o ~/.config/age/keys-new.txt`
2. Add both keys to `.sops.yaml`: `age: <old-key>,<new-key>`
3. Re-encrypt: `sops updatekeys secrets/secrets.yaml`
4. Remove old key from `.sops.yaml`
5. Replace `~/.config/age/keys.txt` with `keys-new.txt`

## Dependencies

- `sops` — encrypt/decrypt
- `age` or `rage` — key management
- `bash` — required by the Fish bridge
