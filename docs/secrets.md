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
sops --config .sops.yaml config/app/fish/.config/fish/secrets.yaml
```

SOPS opens your editor. Add entries in dotenv format:

```dotenv
GITHUB_TOKEN=***
OPENAI_API_KEY=***
ANTHROPIC_API_KEY=sk-ant...xxxx
```

Save and close. SOPS encrypts the file automatically.

### 4. Verify decryption works

```sh
sops -d config/app/fish/.config/fish/secrets.yaml
```

Should print your keys in `KEY=VALUE` format.

## How It Works

### At shell startup

**.profile** (bash/zsh login shells) sources `~/.config/fish/conf.d/secrets.sh`:

```text
.profile → secrets.sh → sops -d secrets.yaml → export KEY=VALUE
```

**Fish** (interactive shell) runs `conf.d/secrets.fish`:

```text
secrets.fish → bash subprocess → source secrets.sh → env → re-export in fish
```

### File locations

| File | Role |
| --- | --- |
| `~/.config/age/keys.txt` | Age private key |
| `~/.config/fish/conf.d/secrets.sh` | POSIX loader (bash/zsh) |
| `~/.config/fish/conf.d/secrets.fish` | Fish wrapper |
| `~/.config/fish/secrets.yaml` | Encrypted secrets |
| `dotfiles/.sops.yaml` | SOPS encryption rules |
| `dotfiles/config/app/fish/.config/fish/conf.d/secrets.sh` | Source file linked into `~/.config/fish/conf.d/` |
| `dotfiles/config/app/fish/.config/fish/secrets.yaml` | Encrypted secrets source |

### Rotating the age key

1. Generate a new key: `age-keygen -o ~/.config/age/keys-new.txt`
2. Add both keys to `.sops.yaml`: `age: <old-key>,<new-key>`
3. Re-encrypt: `sops updatekeys config/app/fish/.config/fish/secrets.yaml`
4. Remove old key from `.sops.yaml`
5. Replace `keys.txt` with `keys-new.txt`

## Dependencies

- `sops` — encrypt/decrypt
- `age` or `rage` — key management
- `bash` — required by the Fish bridge (already present)
