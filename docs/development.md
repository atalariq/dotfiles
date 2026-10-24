# DevShell dan services

DevShell adalah default toolchain proyek. `direnv allow` hanya dilakukan setelah
`.envrc` ditinjau; masuk/keluar direktori memuat/melepas environment melalui
nix-direnv. Tidak ada auto-trust, instalasi SDK, atau startup services saat entry.

```sh
nix flake init -t /path/to/dotfiles#go
# Tinjau flake.nix dan .envrc terlebih dahulu.
direnv allow
```

## Template minimal

| Template | Core tools |
| --- | --- |
| go | Go |
| rust | rustc dan Cargo |
| bun-with-services | Bun, Podman dan Compose |

Hanya tiga template ini yang dipelihara. Untuk toolchain lain, tulis `flake.nix`
serta `.envrc` secara manual di proyek sesuai versi dan kebutuhan proyek tersebut.
Template mengekspor Linux x86/ARM dan macOS ARM; versi yang dievaluasi tercatat
pada `VERSIONS.md`. Runtime platform lain tetap perlu diuji pada host tujuan.
Tanpa Nix, cocokkan versi tooling dan gunakan Compose yang sama untuk services.

`nix develop` pada root dotfiles menyediakan alat pemeliharaan repo, bukan
koleksi toolchain bahasa atau services proyek.

## Bun with services

Hanya template ini yang memiliki services. Salin `.env.example` menjadi `.env`,
tinjau kredensial dan port, lalu jalankan perintah eksplisit:

```sh
./services up postgres
./services up redis
./services up observability
./services health
./services down
```

PostgreSQL 17, Redis 8, OpenTelemetry Collector, Prometheus dan Grafana menggunakan
image digest yang dipin. Port dipublikasikan ke loopback; Grafana default 3001
menyisakan 3000 untuk Bun. `down` mempertahankan volume. Jangan memakai penghapusan
volume sebagai cara menghentikan layanan. Lihat README template untuk status,
stop, konfigurasi OTLP dan retensi data.

Podman macOS membutuhkan machine/VM yang disiapkan pengguna. Di Linux dibutuhkan
prasyarat rootless; pada WSL dibutuhkan dukungan distro/kernel yang sesuai.
Memasang executable dari devShell tidak dengan sendirinya menyediakan kernel VM.

## Perintah pemeliharaan

`nix develop` pada root menyediakan Just, nh, formatter, ShellCheck dan tools
pemeliharaan. `just build nama-host` membangun tanpa aktivasi. `build-fast` memakai
satu job/delapan core; pada ThinkPad yang sudah mengaktifkan helper, profile hold
performance mengikuti proses build. Tanpa helper, override build tetap bekerja.

IDE JetBrains dapat diluncurkan dari environment proyek (`nix develop --command
phpstorm .`, misalnya) dan menunjuk SDK/runtime yang sesuai. Jangan membiarkan
pengaturan SDK global mengalahkan versi proyek. Proses IDE yang daemonize mungkin
mewarisi environment instance pertama; tutup instance lama saat menguji setup baru.
