# Pilihan aplikasi

## Dipilih untuk ThinkPad

- **Creative:** Kdenlive, REAPER, Inkscape, GIMP, Blender dan Godot standar/GDScript.
  Shotcut dan OpenCut tidak dipasang bersamaan; OpenCut sedang mengalami rewrite.
- **Design:** figma-linux adalah wrapper komunitas. Pencil.dev sekarang pen.dev;
  paket lokal `pencil-dev` memakai release desktop resmi berversi dan hash tetap.
  Ini berbeda dari Evolus Pencil (`pkgs.pencil`).
- **Development:** RustRover, PHPStorm, GoLand, Android Studio, Neovim, Vim, Git dan
  jj. Git tetap berfungsi; tidak ada konversi repository otomatis. SDK proyek
  berasal dari devshell. Lisensi/akun IDE dan REAPER ditangani pengguna.
- **Utilities:** Television, nh, nix-index-database, Delta, Difftastic, LocalSend,
  scrcpy, LazySQL dan Syncthing. Delta menjadi pager Git; `git dft` memakai
  structural diff. Ctrl-T milik Television dan Ctrl-R tetap Atuin.
- **Media:** OBS, mpv, MPD/RMPC dan Nicotine++ melengkapi pilihan sebelumnya.
  Nicotine++ tidak mendapat folder sharing atau port masuk secara otomatis.
- **Gaming:** Steam, pilihan game/emulator sebelumnya, serta MangoHud per game.
  Profile hold TLP digunakan secara eksplisit melalui launch options.

Zotero tetap tidak dipilih. Jika diperlukan, tambahkan `pkgs.zotero` ke paket
profil; tidak ada toggle/module satu baris yang harus dipelihara.

## Batas platform dan state

Daftar aplikasi ini adalah pilihan ThinkPad, bukan instruksi memasang semuanya
pada setiap contoh host. Ketersediaan paket mengikuti pin: Android Studio belum
tersedia untuk Linux ARM, figma-linux khusus Linux, dan GIMP/Kdenlive dari pin
ini tidak ditawarkan untuk Darwin. Contoh macOS tetap CLI/development; pengguna
bisa memilih aplikasi native yang didukung secara terpisah.

Pen.dev menyediakan artefak Linux x86/ARM dan macOS ARM dalam package lokal.
Integrasi MCP, akun, serta dokumen `.pen` tidak disediakan sebagai kredensial Nix.
Jangan arahkan auto-setup aplikasi ke konfigurasi agen yang ingin tetap immutable;
review dan tambahkan integrasi secara sengaja melalui konfigurasi pemiliknya.

Syncthing dijalankan sebagai user service dengan UI localhost:8384. Pilih folder
serta public device ID lewat UI; identitas privat dan pairing tinggal di runtime.
Sinkronisasi tetap membutuhkan backup data terpisah.

## Rekomendasi yang belum dipasang

LosslessCut untuk trimming cepat tanpa re-encode; Posting untuk koleksi request
API lokal; PDF Arranger untuk tugas PDF; Qalculate! untuk satuan/perhitungan;
Presenterm untuk presentasi teknis Markdown; Ludusavi untuk backup save game;
Restic untuk backup terenkripsi setelah tujuan penyimpanannya ditentukan.

Masing-masing bisa ditambahkan sebagai paket biasa ketika ada kebutuhan nyata.

## Concat dan Kdenlive

Keduanya dipilih pada profil creative ThinkPad. Concat memakai AppImage resmi
v0.2.8 dengan SHA-256 per arsitektur, dibungkus `appimageTools` dari Nixpkgs repo
ini. Paket rilis menghindari kompilasi UI Rust yang sangat berat pada ThinkPad. Tidak ada module
konfigurasi atau integrasi MCP otomatis. Paket dotfiles menyediakan
Linux x86_64/ARM; aplikasi ini tidak dipaksakan pada contoh Darwin.

Setelah build, jalankan `concat` dan `kdenlive`, atau coba Concat tanpa mengganti
profil melalui `nix run .#concat`. Gunakan salinan footage dan proyek terpisah
untuk membandingkan trim, subtitle, preview, audio dan export dengan pengaturan
yang sama. Model AI opsional diunduh manual lewat pengaturan Concat.

[Concat upstream](https://github.com/jub0t/Concat) menjelaskan fitur dan status
beta; tidak ada akun, model atau server MCP yang diprovisikan oleh dotfiles.
