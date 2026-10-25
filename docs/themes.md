# Appearance

`dotfiles.appearance.enable` mengaktifkan Stylix dan dua pilihan prebuilt:
Gruvbox Dark Medium (`gruvbox-dark`) serta Gruvbox Light (`gruvbox-light`).
`dotfiles.appearance.gui` mengaktifkan target GUI yang sesuai OS.

```sh
dotfiles-theme list
dotfiles-theme current
dotfiles-theme set gruvbox-light
dotfiles-theme set gruvbox-dark
```

Perintah mengaktifkan specialisation Home Manager yang sudah dibangun, tanpa
build atau sudo. Aktivasi base pertama diperlukan. Catalogue base diregistrasikan
sebagai indirect GC root agar kedua variant tetap dapat dipilih. Pilihan valid
terakhir dipulihkan saat deployment base; pilihan yang dihapus fallback ke default.
Aktivasi variant tetap memiliki collision checks Home Manager.

## Pemilik konfigurasi

Stylix menggunakan target upstream Kitty, Fish, Fzf, Starship, bat, btop dan Yazi.
Pin ini belum mempunyai target Fastfetch/Herdr; adapter Nix kecil memasok warna,
seperti pada Umbriel, Mango, Noctalia dan Look. Starship mempertahankan nama role prompt
melalui mapping ke Base16. CLI tanpa appearance memakai fallback Gruvbox.

Noctalia mengonsumsi palette dan tidak menghasilkan template aplikasi. Look
mengelola launcher/clipboard, sementara Noctalia tetap memiliki shell/lockscreen.
Warna Look dikirim sebagai custom theme lewat modul upstream yang dapat menggabung
pengaturan writable aplikasi. Pengumpul clipboard Noctalia/cliphist tidak aktif.

Kitty, tmux dan Noctalia menerima permintaan reload bila relevan. Fish dan aplikasi
lain dapat perlu dibuka ulang; jangan menganggap semua proses mendukung hot reload.
Neovim membaca palette opsional tanpa memerlukan rebuild binary editor per warna.
Vim memakai file Vimscript biasa dan fallback mandiri saat disalin tanpa Nix.

## Fonts dan penambahan tema

Sans-serif Inter, monospace Fira Code dengan Nerd Font Symbols Only, dan fallback
serif DejaVu Serif dipertahankan. Times New Roman/EB Garamond tersedia untuk dokumen;
Font Typst diatur pada proyek masing-masing. Linux GUI memakai Papirus-Dark dan Bibata Modern
Ice 24. Cursor/ikon/GTK/Qt tidak dipaksakan pada host CLI atau macOS.

`themes/` adalah registry scheme dan nilai appearance bersama, bukan kumpulan
aplikasi. Tambahkan scheme Base16 di registry lalu rebuild variant sekali sebelum
memilihnya. Wana yang ditulis ulang kelak dapat memakai interface yang sama.

`tests/activation.py` menguji switching nyata dalam HOME/profile/D-Bus sementara,
termasuk saved selection, fallback dan GC-root reachability. Pengujian tersebut
bukan aktivasi desktop pengguna.

Kedua compositor menerima palet dari adapter yang sama pada tiap specialisation.
Umbriel mengawasi TOML dan memuat ulang sebagian besar pengaturan; Mango memuat
ulang saat config berubah sesuai dukungan upstream. Greeter memakai Gruvbox gelap
dari `themes/` saat rebuild sistem. Switching pengguna tidak menyinkronkan
wallpaper/palet ke greeter dengan privilege tambahan. Lihat [desktop](desktop.md).
