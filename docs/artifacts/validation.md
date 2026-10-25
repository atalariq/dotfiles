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

## Perubahan desktop berikutnya

Umbriel default, Mango fallback, Noctalia Greeter, capture bersama dan perataan
paket Neovim memiliki [catatan migrasi tersendiri](desktop-migration.md). Path
build di atas adalah bukti historis dan dapat sudah tidak tersedia di store;
periksa hasil build terkini, bukan menganggap path tersebut selalu aktif.


## Lanjutan SuperKey — 2026-10-25

Flake checks Linux, evaluasi semua platform, build ThinkPad/Ubuntu dan startup
Neovim yang diuji ulang lulus. Tes headless nyata mencakup PNG/clipboard output
serta jendela, Pluto singleton/persistence dan close guard pada Umbriel/Mango.
Recording dan color picker memiliki fixture jalur berhasil/gagal/cancel;
penerimaan perangkat setelah aktivasi masih terbuka. Lihat matriks, store paths,
status backup dan perintah cutover di [artefak desktop](desktop-migration.md).

## Hardening desktop, 25 Oktober 2026

- Flake checks Linux, evaluasi semua platform dan Neovim startup `--rebuild` lulus.
- Smoke Wayland nyata lulus di Umbriel/Mango: capture clipboard, urutan release,
  repeat/no-repeat, close guard dan flush/persistence shelf saat stop.
- Regresi cutover mencakup GC roots, rollback parsial/interupsi, checksum rusak,
  konflik data baru dan penolakan lintas filesystem sebelum ada pemindahan.
- Regresi audit mencakup traversal gagal, direktori tidak terbaca dan FIFO;
  `vimv` mencakup alias symlink/ancestor dan tracked Git rename; `gignore`
  mempertahankan file lama saat HTTP gagal dan menolak symlink.
- Status ini memverifikasi source/build, bukan aktivasi atau acceptance perangkat.
  Snapshot output final dicatat dalam state privat tool [cutover](../cutover.md).

## Rencana perbaikan OpenCode, 25 Oktober 2026

P1: tes activation theme memeriksa substitusi mock benar-benar terjadi dan command
`nix-store` asli tidak tersisa. Kontrak cleanup ditinjau terhadap source **nh
4.4.2**, dari input nixpkgs terpin: `crates/nh-clean/src/clean.rs`, cabang
`if !is_profile_clean && !args.no_gcroots` melewati seluruh pemindaian/pemangkasan
GC roots ketika `--no-gcroots` aktif. Penghapusan generasi dan store GC adalah
operasi terpisah; store GC tetap menghormati root terdaftar. `just clean` dry-run
lulus dan checksum backup serta enam link root transaksi lama tetap terverifikasi.
Pesan “Performing garbage collection” juga dicetak saat dry-run; source memanggil
command dengan `.dry(args.dry)`. Tidak ada cleanup non-dry yang dijalankan.
Verifikasi ini perlu ditinjau lagi bila versi/pin nh berubah.

P2: live+appearance memerlukan opt-in eksplisit; helper menolak path foreign;
aktivasi live memeriksa checkout sebelum writeBoundary. P3: toolchain devShell
memuat ripgrep/coreutils/findutils; formatter memakai daftar NUL, tidak berjalan
pada daftar kosong, dan menolak hasil scan parsial. P5: loader dotenv berbasis
eval dipensiunkan; wrapper runtime per aplikasi tetap menjadi satu jalur secrets.
Refactor nixpkgs P4 dan provisioning recipient cadangan tetap pekerjaan terpisah.

Review source independen dengan konteks kosong juga menemukan pembacaan secrets
yang gagal dapat tertutupi status `export`, serta pemeriksaan variabel EDITOR
Fish yang keliru. Wrapper kini memisahkan assignment dari export dan memakai cat
terpin; tes membuktikan file hilang maupun error baca tidak meluncurkan child,
dan nilai multiline/sintaks shell tetap literal. `todo` memakai `set -q EDITOR`;
pemeriksaan Fish dengan EDITOR=vim mempertahankan pilihan pengguna.

## Recovery aktivasi Home Manager, 25 Oktober 2026

Diagnosis langsung: system aktif sudah menunjuk build `pgngkwn...`, system profile
masih generasi sebelumnya, service Home Manager gagal, sedangkan transaksi
`FaV5RUvv` masih prepared dan jurnal kosong. Pemeriksa collision Home Manager asli
mereproduksi `.bashrc would be clobbered` dengan exit 1 tanpa menjalankan aktivasi.
Semua checksum backup, audit HOME serta raw/effective tar compare lulus. Hash
konfigurasi Codex pribadi tetap cocok.

Handoff berantai kini mengautentikasi sudo sebelum relocation dan memanggil
rollback HOME jika switch/verifikasi gagal. Tes terisolasi mencakup autentikasi
 gagal, relocation gagal, switch gagal, verifikasi gagal dan sukses terverifikasi.
Probe `sudo -n true` menghasilkan `sudo: a password is required`; HOME belum
dipindahkan oleh agent. Aktivasi nyata tetap menunggu command di terminal pemilik.
Error Lerd `/bin/mkdir` pada quadlet merupakan follow-up terpisah.

Review independen handoff juga menyorot lifetime lock dan pencatatan kegagalan.
Lock transaksi kini dipegang parent sampai switch/verifikasi selesai; child
cutover berbagi descriptor yang sama setelah pemeriksaan identitas file lock.
Proses rollback terpisah ditolak selama lock dipegang. Tes memakai helper cutover
asli untuk memverifikasi protokol lock, serta memastikan kegagalan pencatatan
hasil tidak mencegah percobaan rollback. Helper/tool immutable baru dipertahankan
sebagai root tambahan; root versi sebelumnya tetap disimpan.
