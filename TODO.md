# TODO

## Migrasi tooling Nix + POSIX Shell

Urutan berikut adalah kriteria penerimaan, bukan klaim bahwa port atau host telah
selesai. Helper Python lama dipertahankan sampai regresi pengganti dan cutover
host terbukti; Python proyek dan dependency upstream tetap diperbolehkan.

- [ ] Bootstrap dengan Nix saja, runtime dari pin tanpa evaluasi seluruh flake;
  pertahankan CLI `dot plan|doctor|build|apply|update`.
- [x] Pindahkan validasi manifest, seleksi aplikasi, deteksi target ganda dan
  snapshot allowlist ke Nix; pertahankan isolasi credential/state/override.
- [ ] Verifikasi aktivasi Home Manager sebagai penulis link; implementasi native menuju checkout hidup,
  deklaratif menuju hasil Nix. Manifest tetap satu-satunya inventaris mapping.
- [x] Port renderer tema ke Nix, bandingkan 57 keluaran lama/baru; Shell mengatur
  sync/check dan selector runtime, HM memiliki target link tema.
- [ ] Port `agent-work`, initializer dan OmniRoute ke Shell/jq/curl; buktikan
  validasi tiket, konflik, direktori vendor eksklusif, private state dan tanpa
  fallback berbayar. Operasi yang tak aman harus gagal sebelum menulis.
- [ ] Audit helper Python aplikasi berdasarkan pemakaian; pertahankan fitur
  native dan hapus hanya sumber yang terbukti tidak digunakan.
  Completion OmniRoute sudah jq; `serve [port]` sudah menggunakan miniserve
  sesuai pilihan pemilik. Binary/HTTP nyata menunggu instalasi host. Kitten
  preview tanpa caller tidak lagi dideploy; sumber kompatibilitas masih ditahan.
- [ ] Pensiunkan migrator layout/cutover otomatis dan `git-modes --apply` setelah
  migrasi; sediakan audit read-only, prosedur manual, serta tes command lama
  ditolak tanpa mutasi filesystem.
- [ ] Jalankan syntax POSIX/ShellCheck dan regresi Shell/Nix: quoting, path
  berspasi, konflik/symlink, kegagalan proses, credential isolation, idempotensi.
  Ekspor pemeriksaan melalui `nix flake check`; jangan melemahkan assertion.
- [x] Periksa akses daemon, jaringan dan Podman tanpa mengubah permission socket;
  jika terhalang, catat blocker serta perintah host yang tepat.
- [ ] Update pin Nixpkgs/devenv/Stylix, evaluasi penuh, parity tema dan build host.
- [ ] Audit target HOME, backup konflik di luar Git, aktivasi HM; buktikan link,
  preferensi native, layanan dan sesi desktop sebelum menghapus compatibility.
- [ ] Selesaikan OpenCode V2, digest image OmniRoute nyata, onboarding provider
  gratis, batas route, tes streaming/tool-call/429.
- [ ] Acceptance proyek: Web, Laravel PostgreSQL/Redis, PDF Typst, Android
  Studio/SDK/device fisik. Akun/lisensi/enrollment/otorisasi device oleh pemilik.
- [ ] Setelah aktivasi sehat, GC hanya store tak direferensikan dengan generasi
  rollback dan data proyek tetap ada; laporkan disk dan RAM secara terpisah.
- [ ] Audit akhir semua tooling/check milik repo bebas pemanggilan Python;
  hapus referensi helper lama hanya setelah tidak ada dependensi aktif.
- [x] Tulis [buku latihan perawatan](docs/2026-10-22-maintainer-handbook.md)
  dengan enam latihan; latihan pemilik belum dinyatakan dipraktikkan.

## Fondasi

- [x] Cocokkan checkout lama dan gabungkan perubahan yang sesuai; lihat [reconciliation](docs/2026-10-22-reconciliation.md).
- [x] Konfigurasi satu OpenSSH agent, GPG/pinentry, keyring, Polkit, dan fingerprint/PAM.
- [x] Deklarasikan kebutuhan media/desktop; tambahkan File Roller dan ouch, lengkapi helper screenshot/OCR.
- [ ] Verifikasi auth di perangkat: enrollment, login/unlock/sudo, keyring, SSH/GPG.
- [ ] Verifikasi screenshot/OCR/recording, MPD dan OBS setelah aktivasi berhasil.
- [ ] Selesaikan pin Stylix asli, parity ekspor tema dan filtered build (akses daemon/jaringan masih perlu dipastikan).
- [ ] Cutover link HOME dengan backup/ownership audit; lalu hapus sumber/alias yang tertahan.

## Tahap berikutnya

- [x] Satukan bootstrap/tools dalam `script/`; CLI deploy hanya melalui Nix.
- [x] Hapus mise/toolchains dari instalasi dan shell; tahan sumber mise sampai cutover link HOME.
- [x] Pecah delapan devshell menjadi modul package/command/environment, dengan builder bersama.
- [x] Tanggal/provenance dokumen dan [indeks kronologis](docs/README.md).
- [x] Audit mode Git read-only: `script/git-modes`; `--apply` dipensiunkan, perbaikan manual mengikuti operasi.
- [ ] Cutover manual dengan backup target HM; writer Python lama dan tesnya hanya referensi. Cutover host belum dijalankan.
- [x] Implementasi OpenCode V2 gratis + handoff Codex, command prompt dan validator tiket; aturan global Codex aktif dipertahankan.
- [x] Implementasi devenv Web/Laravel/Typst/Android, Node24/Bun, PostgreSQL/Redis dan template laprak; initializer membawa konfigurasi mandiri.
- [x] Implementasi service user OmniRoute rootless/login dengan guard image digest dan state privat.
- [ ] Update pin Nixpkgs/devenv/Stylix, loading OpenCode V2 asli, build penuh dan aktivasi (daemon Nix ditolak sandbox).
- [ ] Pin image OmniRoute nyata, onboarding akun gratis/key lokal, pembatasan model serta tes streaming/tool-call/429 (Podman/registry belum bisa diakses).
- [ ] Verifikasi build Web, PostgreSQL/Redis Laravel, PDF Typst dan Android Studio/SDK/device fisik.
- [ ] Setelah aktivasi sehat, preview/GC store yang tidak direferensikan; tahan semua generasi rollback dan laporkan disk/RAM terpisah.
- Integrasi IDE/aplikasi development lebih lanjut (shell Nix sudah tersedia di `devshells/`):
  - PHP Laravel (devenv.sh + Nix; nvim / PhpStorm; Sail mengikuti proyek yang sudah memakainya);
  - Android Development (Android Studio);
  - Rust learning journey & Projects (nvim / RustRover);
  - Golang (nvim / Goland);
  - Web Development HTML + CSS + JS/TS (nvim / WebStorm)
- Setup Collaboration Apps (`work.nix`): Plane.so, Linear, Slack, Discord
- Setup Academic Tools (`academic.nix`): Typst, Zotero, Anki, Obsidian
- Setup Creative tools: REAPER (DAW), Kdenlive/Opencut/Concat (Davinci Resolve/Premiere Pro/CapCut alternative)
- Setup hacking / pentesting tools (`hacking.nix`): pentest lab (OWASP Juice), basic hacking tools, etc.
- NixOS Ricing: Mangowm + Noctalia, Fonts, Icons, Theme, Widget, etc.
- Setup NixOS gaming (`gaming.nix`): Steam, MCPE Launcher, osu!, DOOM, GBA, PS1, SNES, PS2
- Rewrite lanjutan Agentic Tools: claude-code, konfigurasi Codex di luar handoff, agy, hermes, SOUL.md, TASTE.md, DESIGN.md, RTK, Tirith, etc.
- Setup Hermes Agent; OpenCode V2 menunggu verifikasi host di atas.
- [x] Buat vimrc plugin-free; eksekusi Vim asli belum diverifikasi (binary tidak tersedia).

## Next steps

- Setup Homelab (Alma Linux 10): MPD?, Jellyfin, NextCloud, Immich, etc.
- Setup VPS (Oracle Cloud; Alma Linux 10): Deployment, Terraform, etc.
