# Syncing Across Machines

One repo, one `main` branch, many machines (Arch laptop, Ubuntu VPS, macOS).
**Per-device differences live in profiles, not branches.** A commit made on any
machine is pulled by the others; each machine only deploys the modules its
profile lists.

## Model

- **Single source of truth:** `main`. No per-machine branches, no long-lived
  forks. Everything portable lands on `main`.
- **Device selection:** each machine runs its own profile
  (`profiles/<host>.json`) — `laptop` (Arch, full), `vps` (Ubuntu, lean),
  and so on. OS-specific shell config is a `system/<os>` module the profile picks.
- **Secrets** stay encrypted (SOPS/age) and travel in the repo; each machine
  needs the age key to decrypt. See `docs/secrets.md`.

## Everyday sync

On any machine, before and after editing:

```bash
cd ~/Repos/dotfiles
git pull --rebase                     # take others' changes first
# ...edit configs...
./setup.sh profile <host>             # re-link if module set changed
git add -p && git commit -m "feat(scope): ..."   # conventional commits
git push
```

Rebase (not merge) keeps history linear across devices. If a pull conflicts,
resolve, `git rebase --continue`, then push.

## Adding a machine-specific difference

Do **not** branch. Instead:

- **Different tool set, shared** → edit that machine's `profiles/<host>.json`.
- **Different tool set, this machine only** → drop a `profiles/<host>.local.json`.
  When present it is used *instead of* `<host>.json` (copy the base and tweak).
  `*.local.*` is gitignored, so it never leaves the machine. Same command:
  `./setup.sh profile <host>` picks the `.local` variant automatically.
- **Different OS shell** → add/extend a `config/system/<os>/` module and point the
  profile at it (`system/ubuntu`, `system/mac`, `system/archlinux`).
- **Truly local, never-shared values** → keep them out of git via the existing
  `*.local.*` / `*.private.*` `.gitignore` patterns.

## Bootstrapping a fresh VPS (Ubuntu)

```bash
# 1. Prereqs
sudo apt update && sudo apt install -y git python3 fish

# 2. Clone + deploy the lean server profile
git clone git@github.com:atalariq/dotfiles.git ~/Repos/dotfiles
cd ~/Repos/dotfiles
./setup.sh profile vps

# 3. Yazi upstream plugins (see docs/yazi.md)
cd ~/.config/yazi && ya pkg install && cd -

# 4. Secrets (needs the age key present at ~/.config/sops/age/keys.txt)
./setup.sh secrets
```

The `vps` profile pulls `system/ubuntu`, whose shell configs degrade gracefully
when `nvim`/`bat` are absent (falls back to `vim`/`vi`, `less`).

## Git commit signing (`~/.gitconfig.local`)

The tracked `app/git/.gitconfig` is portable and does **not** sign commits — a
fresh machine commits unsigned and never hits a missing-key error. Signing and
credential helpers are device-specific and live in an untracked
`~/.gitconfig.local`, pulled in via `[include]`. To enable signing on a machine
that has your SSH signing key:

```bash
cat > ~/.gitconfig.local <<'EOF'
[user]
	signingkey = ~/.ssh/<your_signing_key>
[commit]
	gpgsign = true
[tag]
	gpgSign = true
EOF
```

Add `[credential]` helpers there too if the machine needs them (e.g. libsecret on
a Linux desktop, `gh auth git-credential` for GitHub).

## Theme drift

Theme files are vendored (committed), so a plain `git pull` syncs them. If you
regenerate from the wana palette, run `script/theme-sync` and commit before
pushing; other machines pick it up on their next pull. `theme-sync --check`
guards against drift.
