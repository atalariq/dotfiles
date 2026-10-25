# Model konfigurasi

## Host choices and reusable features

Host memilih profil dan menyimpan identitas/platform. Profil menyusun workflow;
modul menjelaskan perilaku satu program atau layanan. Karena itu rsync, Vim,
Kitty, dan Godot tidak perlu dikategorikan ulang setiap kali workflow berubah.

```nix
{
  imports = [ /path/to/dotfiles/modules/home-manager ];
  home.username = "alice";
  home.homeDirectory = "/home/alice";
  home.stateVersion = "26.05"; # Pertahankan nilai instalasi yang sudah ada.
  programs.fish.enable = true;
  programs.ripgrep.enable = true;
  dotfiles.programs.vim.enable = true;
}
```

Gunakan opsi Home Manager upstream terlebih dahulu. Tambahkan paket biasa ke
`home.packages` dalam profil bila tidak ada konfigurasi tambahan; Zotero cukup
`pkgs.zotero`, tanpa modul enable tersendiri. Opsi `dotfiles.programs.*` hanya
tersisa untuk integrasi khusus yang belum digantikan modul upstream.

Katalog program membaca file Nix dan direktori aplikasi langsung secara
alfabetis. Direktori privat berawalan `_` bukan modul. Import katalog tidak
mengaktifkan aplikasi. Profil sengaja mengaktifkan beberapa fitur sekaligus.

Desktop berisi compositor, shell, portal dan integrasi sesi; aplikasi GUI
berada di program/profil GUI atau creative. Modul NixOS mendaftarkan sesi Umbriel/Mango dan greeter secara independen;
Home Manager mengatur keybinding dan konfigurasi pengguna. Host memilih default
Umbriel dan geometry layar, dengan Mango sebagai fallback. Modul capture memiliki
workflow screenshot/recording/color picker bersama. `desktop/shortcuts.nix` menjadi
sumber binding kedua compositor; `desktop/shelf.nix` mengelola Pluto. Keyd hanya
dipilih ThinkPad; `dotfiles.desktop.capture.enable` pada NixOS menyediakan integrasi
KMS GPU Screen Recorder. Lihat [desktop](desktop.md) untuk peta kepemilikan. Host macOS/Ubuntu tidak perlu mengimpor modul sistem NixOS.

## Source modes

`dotfiles.deployment.mode = "immutable"` adalah default. File native yang masih
ada mengikuti generasi. `live` dengan `dotfiles.deployment.checkout` eksplisit
hanya memengaruhi sumber yang memakai helper tersebut. Fish, Git, Starship,
Fastfetch, fd, ripgrep, Fzf, Herdr, Kitty dan pengaturan Yazi kini dihasilkan Nix;
perubahan opsi tersebut memerlukan rebuild, termasuk dalam mode live.

Tmux dan Vim memiliki sumber mandiri yang bisa disalin tanpa Nix. Lua Neovim,
plugin Yazi, serta completion Fish tetap memakai bahasa aplikasinya; konfigurasi
dan pemasangannya dideklarasikan Nix. `packages/neovim.nix` membangun nvf yang memiliki plugin dan executable editor;
tidak ada plugin manager kedua yang mengunduh saat startup.

## Runtime state and ownership

Jangan mengelola direktori writable secara keseluruhan ketika aplikasi menyimpan
state di sana. Token, sesi Codex, history shell, identitas Syncthing, proyek,
SDK Android dan dokumen berada di luar Nix store. Look memakai merger konfigurasi
upstream karena aplikasinya juga menulis pengaturan melalui UI.

Syncthing tidak mempunyai default folder atau perangkat pasangan. UI berada di
localhost:8384; pairing/folder yang ditambahkan lewat UI tidak dibuang rebuild.
LazySQL menggunakan kredensial runtime; jangan menaruh password di opsi Nix.

## Literate source

Nix adalah sumber utama, bukan hasil ekstraksi Markdown/Org. Komentar menjelaskan
alasan dan batas perilaku dekat opsi terkait; handbook ini menghubungkan bagian
tersebut. Contohnya komentar profil daya pada modul hardware, pemisahan host dan
per-platform output di flake, serta pemilihan toolchain pada profil development.

Latihan: tambahkan satu paket ke profil, lihat `git diff`, jalankan `just build`
untuk host yang dipilih, lalu baca [catatan keputusan](decisions.md). Untuk
aplikasi dengan konfigurasi, buat satu modul alfabetis dan verifikasi katalog
tetap inert sebelum fitur diaktifkan.

[Appearance dan switching](themes.md) menjelaskan state tema dan pemilik warna.

Live mode dengan appearance ditolak secara default karena file bertema dihasilkan
ke Nix store. Jika kombinasi ini disengaja, tetapkan
`dotfiles.deployment.allowThemedFiles = true`; evaluasi memberi warning bahwa
edit file bertema tetap memerlukan rebuild. Sumber native lain tetap mengikuti
checkout. Helper live menolak path dari luar source tree agar tidak menghasilkan
symlink palsu. Checkout harus berupa path absolut dan tersedia sebelum tahap
aktivasi yang menulis HOME; jika pindah, perbarui opsi `checkout` terlebih dahulu.
