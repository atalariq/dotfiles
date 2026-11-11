# Self-hosted clients

The homelab serves the library; the ThinkPad, phone and e-reader consume it.
This page records which client is used for which service, and the parts that
are configured by hand because they are writable runtime state.

## Services and clients

| Service | Where it runs | Client | Notes |
|---|---|---|---|
| Navidrome | homelab `:4533` | Ratune, NaviBeat | see [navidrome-clients.md](navidrome-clients.md) |
| Jellyfin | homelab `:8096` | browser + VLC | download, then play locally |
| BookOrbit | homelab `:3000` | web + KOReader | EPUB/PDF library |
| Memos | homelab `:5230` | web + `memo` | shell helper in `fish/functions` |
| Paperless | homelab `:8010` | web | OCR archive for course documents |
| ntfy | homelab `:2586` | phone app | topic per script or host |
| Stirling PDF | homelab `:8082` | web | merge, split, OCR, convert |
| Seerr | homelab `:5055` | web | requests for Sonarr/Radarr |

Everything except Jellyfin and Navidrome is reached over the tailnet or the
LAN; nothing is exposed to the internet.

## Jellyfin: download, then VLC

The Jellyfin desktop application was removed. It is a Chromium shell that
argues with Wayland, and the file it plays is already available from the web
UI. The working flow is:

1. Open Jellyfin in the browser and download the episode or film.
2. Play the downloaded file in VLC, which handles hardware decoding and every
   container the server has.

This keeps the client list short and removes a large Electron bundle from the
system closure.

## KOReader

KOReader opens the BookOrbit library from the local folder. It is the same
reader used on e-ink, which means highlights, dictionary lookup and progress
carry over conceptually even though the sync itself is manual.

## Syncthing

Syncthing is enabled as a Home Manager service, but the device list and
folders are deliberately left to the web UI (`127.0.0.1:8384`). Declaring
them in Nix would overwrite the runtime config every time a phone is paired.
The device identity lives under `~/.local/state/syncthing` and is not in Git.

Pair the ThinkPad with the phone and share the course folder. No cloud relay
is used; on the same LAN the transfer is direct.

## memo

`memo` posts to the Memos API:

```sh
memo remember to renew the library loan
echo "longer note" | memo
```

The access token is read from `MEMOS_TOKEN`, or from
`~/.config/memos/token` (not in Git). Create one in Memos under
**Settings -> Access tokens**. `MEMOS_URL` overrides the default
`http://homelab-x456urk:5230`.

## Paperless

The admin user is created once, manually, because the password must not live
in the Nix store:

```sh
ssh homelab-ts 'sudo paperless-manage createsuperuser'
```

Drop course scans into `/var/lib/paperless/consume` on the homelab, or upload
them in the web UI. OCR runs for English and Indonesian.
