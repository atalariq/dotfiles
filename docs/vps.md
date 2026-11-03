# VPS (Oracle Cloud Always Free)

The public VPS is an Oracle Ampere A1 instance (`2 OCPU`, `12 GB`, `200 GB`)
running AlmaLinux 10. It is the public edge and always-on lightweight host; the
homelab keeps storage-heavy and private services. Configuration lives outside
this Nix flake, so this page is the deployment contract.

## Cloudflare and certificates

- Web apps: proxied through Cloudflare, SSL mode **Full (strict)**.
- `headscale.atalariq.dev`: **DNS only** (grey cloud). Headscale is not
  supported behind the Cloudflare proxy/tunnel because the Tailscale control
  protocol needs WebSocket POST/TS2021 traffic.
- Certificates: Let's Encrypt **DNS-01 wildcard** using a scoped Cloudflare API
  token, or Cloudflare Origin Certificates for proxied origins. Keep the API
  token in `/etc/letsencrypt/cloudflare.ini` (0600), never Git.
- Restrict the origin firewall to Cloudflare IP ranges for proxied web apps.
  Headscale needs direct TCP/443; embedded DERP also needs UDP/3478.
- Enable Authenticated Origin Pulls if the origin is only reached through
  Cloudflare.

## Nginx

Keep nginx: it is the industry-standard skill the owner wants to practise.
Use it as the only public entrypoint:

- `auth.atalariq.dev` -> Authelia
- `passbolt.atalariq.dev` -> Passbolt
- `karakeep.atalariq.dev` -> Karakeep (Authelia protected)
- `status.atalariq.dev` -> Gatus public status page
- `analytics.atalariq.dev` -> Umami (Authelia protected)
- `headscale.atalariq.dev` -> Headscale (DNS only, direct TLS)

## Authelia

Authelia is the forward-auth gate, not a full IdP:

- nginx `auth_request` to Authelia.
- File backend first; Redis for sessions.
- TOTP/WebAuthn for MFA.
- Protect Passbolt, Karakeep, Umami, and any admin dashboards.

Passbolt Community Edition does **not** support SSO/OIDC (Pro/Enterprise only).
Authelia can gate the Passbolt web UI, but Passbolt keeps its own login. Personal
passwords stay in Bitwarden Cloud; Passbolt is for shared/family vaults.

## Services

| Service | Exposure | Notes |
|---|---|---|
| nginx | public | TLS, reverse proxy, Cloudflare origin |
| Authelia + Redis | public | forward auth, MFA |
| Passbolt CE | public | shared vaults; no OIDC in CE |
| Karakeep | public behind Authelia | arm64 image check; Postgres + Meilisearch |
| Gatus | public status page | YAML config |
| Beszel hub | tailnet only | agents on homelab/VPS |
| Umami | public dashboard behind Authelia | Postgres |
| Headscale | public, DNS-only | control plane; backup DB + noise key |

## Headscale

- URL: `https://headscale.atalariq.dev`
- DNS record must be **DNS only**.
- Open TCP/443 and, if using embedded DERP, UDP/3478.
- Back up the SQLite database and the noise private key.
- Use tags/ACL for `homelab`, `vps`, `phone`, `family`.
- If Headscale is down, remote access to every tailnet node is down; keep an
  emergency SSH path to the VPS.

## Backups

Restic to Cloudflare R2 is the only backup target:

- Use a bucket/application token scoped to the backup prefix.
- Enable object versioning and a lifecycle policy.
- Store `RESTIC_PASSWORD` and R2 keys outside Git.
- Run a restore test periodically. R2-only is not 3-2-1; document the accepted
  risk and keep at least one offline copy if the data matters.

## Images and ARM

- Every container must have an `linux/arm64` image. Check with
  `docker manifest inspect` or `podman manifest inspect`.
- Karakeep's browser/Meilisearch stack is the most likely arm64/ARM-memory
  problem; fall back to the homelab x86_64 host and expose it through Headscale
  if the VPS image is unavailable.
- AlmaLinux 10 uses `dnf`; install nginx, certbot, podman, and run app
  containers with systemd units or `podman-compose`.
