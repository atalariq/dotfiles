# Verifikasi redesign — 2026-10-24–25

Verifikasi sumber/build dipisahkan dari acceptance desktop. Tidak ada aktivasi
sistem atau profil Home Manager pemilik dalam pengerjaan ini.

## Sumber dan kepemilikan

- Baseline implementasi: `570bdbf` pada branch `dev`.
- Semua pin input lama dipertahankan; input baru ditambahkan secara terpisah.
  Perbandingan mengikuti nama input/follows, bukan ID node lock yang bisa berubah.
- Hardware/per-device dan stateVersion instalasi dipertahankan.
- Pengaturan pribadi Codex tetap berada di working tree dan tidak masuk commit.
- Katalog program alfabetis menggantikan kelompok kategori lama. Profil menyusun
  workflow; desktop dan appearance terpisah dari aplikasi GUI.
- Konfigurasi native yang sudah digantikan opsi Nix dihapus dari repo. Completion
  Fish, Lua/plugin Yazi, sesi Kitty, serta sumber mandiri tmux/Vim tetap tersedia.
- Link HOME yang menunjuk sumber berpindah diperbaiki. Sebelum sumber native lama
  dihapus, salinannya disimpan privat dan 15 link aktif diarahkan ke salinan itu.
  Link config Mango aktif juga diarahkan ke salinan privat sebelum include warna
  Noctalia lama dibersihkan; aplikasi sesi lama tidak lagi menulis ke sumber repo.
  Ini mempertahankan sesi lama tanpa menyimpan compatibility layer dalam repo.
- Backup privat: `~/.local/state/dotfiles-v3-backup/` (patch awal, arsip sumber,
  inventaris link dan `native-before-nix/`). Backup/GC root migrasi sebelumnya
  `~/.local/state/dotfiles-cleanup-20261024-173644/` tetap dipertahankan.
  Tidak ada garbage collection atau penghapusan generasi rollback.

## Hasil pengujian

- Sebelas check native mencakup katalog inert, fitur sistem independen, source
  modes, direnv, theme switching, command routing, startup Fish/Yazi, runtime
  helpers, shell syntax, Neovim dan Vim mandiri.
- Startup Fish memakai config hasil Home Manager; tanpa pacman/brew inisialisasi
  tetap mencapai abbreviation berikutnya. Helper Yazi benar-benar mengganti
  direktori shell menggunakan executable mock dalam HOME sementara. Tes juga
  memeriksa Ctrl-R Atuin, Ctrl-T Television dan absennya binding huruf `c,r`.
- Tes direnv nyata memakai template Go: entry Bash/Fish, cached re-entry dan
  unload lolos dalam HOME sementara.
- Aktivasi Home Manager terisolasi menguji dark/light, pemulihan pilihan, fallback
  pilihan invalid dan reachability GC root. Tidak menggunakan profil pemilik.
- Ketiga devShell yang dipertahankan dievaluasi untuk x86_64-linux, aarch64-linux dan
  aarch64-darwin. `VERSIONS.md` mencatat versi dari derivasi. Runtime foreign-platform tetap memerlukan mesin tujuan.
- Paket Pen 1.2.19 Linux x86 berhasil dibangun dengan hash artefak resmi, pemeriksaan
  autoPatchelf, wrapper executable dan ikon dari bundle aplikasi.
- Link Markdown lokal dan whitespace diff diperiksa. Review spesifikasi dan
  standar telah diulang setelah perbaikan Fish, Yazi, Kitty dan ikon Pen;
  tidak ada temuan konkret yang tersisa.

Build penuh sempat terputus saat PC mati dan dilanjutkan dengan dua job/dua core.
Concat v0.2.8 memakai AppImage resmi dengan SHA-256 terpin untuk dibandingkan
dengan Kdenlive;
model AI dan integrasi MCP tetap opt-in. Template proyek selain bun-with-services,
go dan rust dihapus atas pilihan pengguna; pengujiannya tidak menjadi syarat
hasil akhir. Build paket rilis Concat lolos, demikian pula `--version` dan
`--whisper-cpu` dalam HOME sementara. Build source upstream dihentikan setelah
paket rilis terverifikasi karena kebutuhan RAM/swap dan waktu kompilasinya tinggi.
Build final ThinkPad dan Home Manager Ubuntu lolos:

```sh
nix build .#nixosConfigurations.thinkpad-x13.config.system.build.toplevel \
  .#homeConfigurations.ubuntu-x86_64-linux.activationPackage \
  --max-jobs 2 --cores 2 --no-link
```

- ThinkPad: `/nix/store/br8g8cjakqid59rp3j2a0c36d480hc58-nixos-system-thinkpad-x13-26.11.20261020.02c087f`.
- Ubuntu: `/nix/store/bs6j38766c8iz1sp46pq44igqga77i17-home-manager-generation`.
- Concat: `/nix/store/5dqlm405k4y99rq8qf77yk5wzrf3v1mv-concat-0.2.8`.
- Evaluasi `nix flake check --all-systems --no-build` final lolos, termasuk
  derivasi paket Concat Linux ARM. Ini tidak menggantikan runtime native ARM.
- Native flake check terakhir juga lolos sebelas check. Packaging Concat dan
  perbaikan binding Fish diperiksa ulang tanpa temuan konkret tersisa.

## Acceptance yang masih memerlukan host

- Periksa konflik HOME sebelum apply, termasuk direktori symlink dan konfigurasi
  native lama di backup. Pindahkan hanya leaf yang telah dibackup/dipahami.
- macOS/ARM/WSL: evaluasi bukan bukti boot, aktivasi maupun runtime OS tersebut.
- ThinkPad: login/PAM/keyring/SSH-GPG, portal, launcher/clipboard Look, reload tema,
  suspend, cabut/pasang charger, TLP/tlp-pd, audio USB dan perangkat Android.
- Aplikasi GUI, pairing Syncthing, kredensial, SDK licenses dan emulator opsional
  memerlukan acceptance pengguna. Tidak ada perangkat/folder sync otomatis.
- Ukur frametime/temperatur dan build Gradle dengan workload yang sama sebelum
  menyimpulkan peningkatan performa atau penghematan baterai.
