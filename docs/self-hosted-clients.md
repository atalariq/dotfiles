# Media workflow and clients

The homelab is a media server and a Nix playground; the clients below are the
ones that touch it. Anything that is not media was removed on purpose.

## Where files go

| Path | Holds |
|---|---|
| `/data/media/downloads/incoming` | aria2 output, waiting for import |
| `/data/media/downloads/music-incoming` | music waiting for `beet import` |
| `/data/media/movies`, `/data/media/series` | Sonarr/Radarr libraries |
| `/data/media/music` | Navidrome library, tagged by beets |

Kept on one filesystem so imports and hardlinks never cross a device.

## Adding a movie or episode

aria2 runs on the homelab, not the ThinkPad:

1. Point the Aria2 Explorer extension at
   `http://homelab-x456urk:6800/jsonrpc` with the RPC secret.
2. Send the download; it lands in `/data/media/downloads/incoming`.
3. In Sonarr/Radarr, open **Wanted -> Manual Import**, select the folder, and
   confirm the match. They rename, move and tell Jellyfin.

No manual metadata step: Sonarr/Radarr query TheTVDB/TMDB during import. If a
release is still downloading on the laptop, `just media-push <path>` copies it
into the same folder over the direct link or tailnet.

Files land as `atalariq:media 0664` regardless of how they were downloaded:
setgid directories decide the group, and the recipes set the mode. Nothing
needs a manual chmod before Jellyfin or Navidrome can read it.

`Prowlarr` only automates indexers that expose an API. Direct-download pages
have no such API, so they always go through aria2 + Manual Import. Torrent
indexers wired through Prowlarr can be fully automatic via qBittorrent.

## Adding music

```sh
ssh homelab-ts
beet import /data/media/downloads/music-incoming
```

beets matches the release, writes tags and moves the files into
`/data/media/music/<albumartist>/<album>/`. Navidrome rescans on its own.

If a quiet import skips an album it has seen before, beets still records the
path as imported. Re-run with `-I` (ignore the import cache) and
`-A` (keep the tags already in the files) when the release will not match.

## Clients

| Service | Client | Notes |
|---|---|---|
| Jellyfin | browser + VLC | download, then play locally; no desktop app |
| Navidrome | Ratune, NaviBeat | see [navidrome-clients.md](navidrome-clients.md) |
| Seerr | web | requests for Sonarr/Radarr; enter API keys once |
| Gatus | web | status page at `:9000`, checks every service health endpoint |
| BookOrbit | removed | local EPUB/PDF files open in KOReader instead |

Syncthing is still enabled on the ThinkPad for course files; its device list
stays in the web UI at `127.0.0.1:8384` rather than in Nix.

## Attic

The homelab also serves a private Nix cache. The ThinkPad substitutes from it
and pushes closures with `just cache-push`. The token lives in
`~/.config/attic/config.toml`, outside Git; `attic cache info main` prints the
public key recorded in the host configuration.
