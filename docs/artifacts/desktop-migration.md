# Migrasi desktop — 2026-10-25

Baseline: commit `b763305` pada branch `dev`. Perubahan pribadi Codex di working
tree tidak termasuk pekerjaan ini. Catatan ini melengkapi, bukan mengganti,
[hasil redesign sebelumnya](validation.md).

## Status lanjutan terbaru

Ringkasan ini menggantikan status historis di bagian bawah. Implementasi rencana
SuperKey tetap menjadi tujuan utama. Backend recording mengikuti keputusan
terakhir pemilik: GPU Screen Recorder, dengan satu service, audio monitor sistem,
MP4 H.264 60 fps dan fallback CPU. Pemakaian wf-recorder dalam rencana awal sudah
digantikan keputusan tersebut.

Audit ulang source memverifikasi tabel bersama delapan shortcut, keyd ThinkPad,
adapter sesi, capture/OCR/Satty, close guard, shelf, color picker dan integrasi
Noctalia/Look/Espanso/scratchpad. Umbriel kini menetapkan `mod_key = "Super"`
secara eksplisit; upstream Auto memakai Win pada native dan Alt pada nested.
Tes binding memeriksa pilihan modifier produksi, selain kesetaraan serializer.
Bug IPC `capture-window info` yang sempat mengembalikan sukses kosong diperbaiki;
tes regresi memastikan error/no-focused-window tidak menghasilkan output sukses.

**Pekerjaan belum selesai:** migrasi HOME dan keberhasilan aktivasi Home Manager,
lalu acceptance perangkat pada kedua sesi. Pemeriksaan host terakhir menemukan
Home Manager gagal karena file “would be clobbered”, sementara transaksi lama
masih prepared dan jurnal kosong. System aktif sudah mencapai generasi baru;
itu tidak membuktikan HOME sudah ikut termigrasi. Backup/link/isi efektif serta
hash Codex telah diverifikasi. Handoff lama digantikan setelah build snapshot
terbaru; gunakan command berantai pada [panduan cutover](../cutover.md).

Acceptance yang masih memerlukan perangkat: Caps tap/hold dan pelepasan modifier,
rekaman GPU/CPU dan audio monitor tanpa mikrofon, dimensi/playback MP4, selektor
interaktif, pixel/color-picker, drag shelf file/folder/teks/link/gambar, serta
login greeter sesudah reboot manual. Smoke headless menguji protokol nyata dan
input virtual; tidak menggantikan acceptance tersebut. Backup/generasi pemulihan
serta perubahan Codex pribadi dipertahankan. Reboot dan commit menunggu acceptance.

Catatan build, hasil tes serta snapshot final disimpan pada transaksi cutover
privat. Bagian-bagian berikut adalah bukti historis yang tetap dipertahankan.

## Kontrak implementasi

| Kebutuhan | Implementasi | Bukti yang harus dicatat |
| --- | --- | --- |
| Umbriel default, Mango fallback | host memilih default; kedua modul sesi aktif | parser kedua compositor, sesi pada greeter |
| Noctalia Greeter | modul native NixOS, satu greetd, PAM lama | evaluasi command/session, login nyata |
| Screenshot siap pakai | satu modul capture, dua backend, seluruh dependency terbungkus | capture-workflow, PNG/protokol native, acceptance kedua sesi |
| Neovim tanpa error conform | aktivasi nvf yang memuat runtime/plugin | repro lama merah; nvf HOME nyata dan sementara hijau |
| Paket editor flat | `packages/neovim.nix` | import/relative path dan check startup |
| Hindari kompilasi lokal | cache resmi dahulu, binary/AppImage resmi terpin | rencana build dan sumber paket |
| Portabilitas | desktop Linux opt-in, registry host tetap | evaluasi seluruh sistem, build Ubuntu native |
| Recovery dan ownership | audit HOME, backup privat, aktivasi terpisah | inventaris konflik dan generasi pemulihan |

## Bukti awal dan sumber

- Repro `nvim --headless -i NONE -n` dengan pemeriksaan `vim.v.errmsg` keluar 1:
  `E5113: module 'conform' not found` dari konfigurasi Lua pemilik.
- Executable lama: `/nix/store/zxri7j6vsx3mdjvcdv33sgsnykwww8sm-neovim-0.12.6/bin/nvim`.
- Paket nvf dari generasi baru memuat `conform` dan startup tanpa error, baik
  dengan config HOME pemilik maupun HOME sementara. Belum mengaktifkan profil.
- Umbriel `0-unstable-2026-10-16`, portal `0-unstable-2026-10-14`, dan Noctalia
  Greeter `1.7.0` diunduh dari `cache.nixos.org`: 7.3 MiB download, 22.8 MiB
  unpacked termasuk xwayland-satellite. Tidak dikompilasi lokal.
- Skrip Mango sesi lama disalin dari baseline ke backup privat mode `0700` di
  `~/.local/state/dotfiles-v4-backup/mango-script/`; link direktori aktif diarahkan
  ke backup saat sumber capture dipindahkan. Inventaris link awal disimpan di
  `mango-script-link.txt`. Tidak ada compatibility layer baru di repo.

## Perintah reproduksi

```sh
nix develop
bash tests/capture.sh "$PWD/modules/home-manager/programs/capture"
nix flake check --no-update-lock-file --max-jobs 2 --cores 2
nix flake check --all-systems --no-build --no-update-lock-file
nix build .#nixosConfigurations.thinkpad-x13.config.system.build.toplevel \
  .#homeConfigurations.ubuntu-x86_64-linux.activationPackage \
  --no-link --max-jobs 2 --cores 2
```

## Status

Pemeriksaan final x86_64 Linux dan evaluasi semua platform lulus. Build ThinkPad
serta Ubuntu x86_64 Linux selesai; startup Neovim juga diuji ulang dengan
`nix build .#checks.x86_64-linux.neovim-startup --rebuild --no-link` dan lulus.
Parser Umbriel/Mango dijalankan sebagai dependency build generasi; keyd `check`
lulus. Aktivasi sistem/profil, reboot dan acceptance perangkat belum dilakukan;
jangan membaca bukti build atau baseline sebagai bukti desktop baru sudah aktif.

## Lanjutan SuperKey dan workflow

Arahan terakhir pemilik mempertahankan **gpu-screen-recorder**, menggantikan
wf-recorder dalam rencana awal. Semua perubahan sumber tetap belum diaktifkan.

| Kebutuhan | Implementasi | Pengujian | Hasil |
| --- | --- | --- | --- |
| Caps Esc / Ctrl+Win+Alt | keyd di host ThinkPad, XKB lain dipertahankan | parser keyd `check`, evaluasi inert host lain | parser lulus; perangkat menunggu aktivasi |
| Delapan shortcut setara | satu tabel Nix, serializer Umbriel/Mango | `desktop-bindings`, parser compositor; Mango kembali ke mode default sebelum tabel | lulus |
| Screenshot desktop/output/area/window | `shot` dan satu adapter sesi | `capture-workflow`, Wayland headless nyata skala 1.25 | PNG/clipboard desktop/output/window lulus kedua compositor; selektor perangkat pending |
| Save/Decorate/Drag, Satty, OCR | helper capture bersama | fixture clipboard, hasil dekorasi, gagal IPC/grim/OCR, cancel | lulus; UI perangkat pending |
| Recording tunggal | user service, SIGINT, Result+ffprobe, MP4/H.264/60 fps, GPU dengan fallback CPU | `desktop-workflow`: stop, cancel, startup gagal, hasil gagal, worker/session | lulus fixture; GPU, audio aktual dan finalisasi perangkat pending |
| Audio sistem saja | monitor sink keluaran eksplisit; monitor absen menggagalkan startup | fixture monitor terpilih, mikrofon diabaikan, monitor absen | lulus fixture; dengarkan hasil setelah aktivasi |
| Area recording aman | satu output, koordinat negatif, scaling logis GSR, limit genap/alignment encoder upstream | fixture area negatif/ganjil/skala 1.25 dan area lintas output ditolak | lulus fixture; cek ffprobe perangkat pending |
| Win+Q dua kali / 600 ms | stream fokus, identitas socket/sesi dan ID jendela, lock ownership | timeout, fokus pergi-kembali, sesi berubah, stale state/SIGKILL; normal close IPC nyata | lulus fixture dan normal close headless kedua compositor; autorepeat/fisik pending |
| Shelf | wheel resmi Pluto 0.1.5, hash tetap, GTK wrapper, satu service D-Bus, `shake=false` | build/import/version/help, singleton/toggle/add/restart/persistence headless kedua compositor | lulus; edge drag dan gambar browser perangkat pending |
| Palet/font shelf | Stylix dan restart service aktif saat tema berubah | evaluasi Gruvbox/font shared, build specialisations | evaluasi/build lulus; tampilan perangkat pending |
| Color picker | hyprpicker, validasi HEX sebelum clipboard | fixture valid/cancel/hasil salah | lulus; pixel perangkat pending |
| Recovery HOME | audit read-only dan arsip privat link+isi efektif dengan checksum | daftar target, baca kedua arsip dan SHA-256 | backup selesai; tidak memindahkan target aktif |

Bukti headless terbaru: `/tmp/dotfiles-umbriel-native.8TBwqm` dan
`/tmp/dotfiles-mango-native.Wam7RR`. Keduanya menguji screenshot asli, clipboard PNG,
shelf pada bus D-Bus privat, serta permintaan tutup normal ke client Kitty privat.
Ketika menguji close, Kitty fixture menonaktifkan dialog konfirmasi penutupan
proses anak; aplikasi pemilik tetap boleh memberi dialog unsaved changes.
Portal pada bus uji dapat memberi peringatan PipeWire/secret-service saat startup
atau teardown; tes ini tidak mengklaim penerimaan screencast/audio/keyring.

Perbaikan hasil review: Decorate tanpa ICC sekarang tetap melanjutkan clipboard
serta aksi berikutnya; close guard memulihkan state setelah pemilik lock mati;
reply sukses Umbriel `msg` divalidasi oleh CLI (payload-nya null). Test native
mengisolasi `XDG_DATA_HOME` selain HOME/config/state/cache; state uji awal yang
sempat memakai data dir host dipindahkan ke direktori bukti `/tmp` setelah isi
empat item fixture diverifikasi. Tidak ada item pengguna yang dihapus.

Perintah tambahan:

```sh
nix build .#checks.x86_64-linux.desktop-bindings \
  .#checks.x86_64-linux.desktop-workflow --no-link
# Di shell dengan tools Wayland, D-Bus dan paket Pluto yang baru dibangun:
PLUTO_BIN=/nix/store/...-pluto-shelf-0.1.5/bin/pluto \
  bash tests/capture-native.sh umbriel "$(command -v umbriel)"
PLUTO_BIN=/nix/store/...-pluto-shelf-0.1.5/bin/pluto \
  bash tests/capture-native.sh mango "$(command -v mango)"
```

Audit menemukan 26 leaf konflik, 6 symlink induk, 37 foreign links, 4 dangling
links dan satu link Neovim lama (kategori dapat berada di bawah symlink induk
yang sama). Backup privat berada di
`~/.local/state/dotfiles-superkey-backup.Ophd3P/`, mode direktori 0700;
53 target terpilih, arsip link 40 KiB dan isi efektif sekitar 5.7 MiB. Manifest,
log audit dan checksum disimpan privat. **Target aktif belum dipindahkan**;
persiapan konflik dan switch memerlukan persetujuan cutover langsung. Generasi
pemulihan serta backup migrasi sebelumnya tetap disimpan.

## Hasil final build dan handoff aktivasi

- ThinkPad: `/nix/store/g7x2jmvfkp0j26szvarnlqbhn0lnfmiy-nixos-system-thinkpad-x13-26.11.20261020.02c087f`.
- Home Manager ThinkPad: `/nix/store/mmk1h0dgzm12xbkgsnk35vxpi288bqh4-home-manager-generation`.
- Home Manager Ubuntu: `/nix/store/cv0qpvppnxy00aqn5h3whdvd4nnbbrr9-home-manager-generation`.
- `nix flake check --no-update-lock-file --max-jobs 2 --cores 2`: lulus.
- `nix flake check --all-systems --no-build --no-update-lock-file`: lulus;
  evaluasi Darwin/ARM bukan runtime atau build lintas arsitektur.
- ShellCheck, nixfmt dan `git diff --check`: lulus. Warning deprecation upstream
  `xorg` masih muncul saat evaluasi dan tidak disembunyikan.
- Audit generasi final sama dengan target backup; perbandingan kedua arsip
  terhadap link/isi HOME saat ini lulus, demikian pula kedua SHA-256.

Backup privat berisi `relocation.list` (53 kandidat setelah parent/leaf
tergabung), `cutover-plan.txt`, generasi sebelum aktivasi, generasi hasil build,
serta log verifikasi. Tidak ada pemindahan target HOME, sudo switch, reboot,
commit, atau penghapusan generasi/backup dalam pekerjaan ini.

Perintah aktivasi yang harus dijalankan pemilik **setelah** persetujuan langsung,
review manifest, audit ulang dan pemindahan konflik yang disepakati:

```sh
sudo nixos-rebuild switch --flake /home/atalariq/.dotfiles#thinkpad-x13
```

Ini adalah perintah handoff; belum ada output switch karena belum dijalankan.
Setelah switch berhasil, lakukan acceptance di `docs/desktop.md`; khususnya
Caps/pelepasan modifier, autorepeat Q, recording GPU/CPU dan audio monitor nyata,
dimensi MP4, selektor/color picker serta drag shelf membutuhkan perangkat.

## Hardening lanjutan (25 Oktober 2026)

Hasil build di atas adalah snapshot sebelum hardening. Sumber sekarang menambahkan
jurnal cutover/GC roots dan menutup kegagalan audit parsial, FIFO, pemindahan lintas
filesystem, serta collision rollback. `vimv` memvalidasi alias/ancestor sebelum
rename; `gignore` mengganti file secara atomik dan menolak symlink; Fish memperoleh
Gio dari `glib`. Shelf menunggu proses selesai menyimpan setelah `pluto quit`.

Review source independen menggunakan agent dengan konteks kosong menemukan
kegagalan rollback lintas filesystem; tes regresi menolak kasus itu saat prepare
dan sebelum relocate. Audit FIFO diuji dengan timeout agar tidak dapat macet.
Temuan diperbaiki tanpa mengubah konfigurasi Codex pribadi atau lock input.

`just desktop-smoke` kini menyediakan smoke test terpin. Kedua compositor nyata
lulus screenshot/clipboard, kedua urutan pelepasan modifier, no-repeat aksi sekali
tekan, repeat navigasi biasa, guarded close, dan persistence shelf termasuk update
terakhir sebelum stop. Portal screencast di lingkungan headless privat tidak
memiliki PipeWire perangkat; hasil ini bukan acceptance audio/recording perangkat.

Handoff checkout mutable sebelumnya digantikan [cutover immutable](../cutover.md).
Manifest privat transaksi baru menyimpan output final dan perintah switch persis.
HOME belum dipindahkan, system belum di-switch, reboot/acceptance/commit tetap
belum dilakukan. Backup dan generasi lama tetap dipertahankan.
