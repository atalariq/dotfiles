# Desktop, login dan capture

ThinkPad memilih **Umbriel** sebagai sesi default, dengan layout scrolling
horizontal dan sembilan workspace pada layar internal. **Mango** tetap terpasang
sebagai fallback dengan layout, aturan dan gesture sebelumnya. Pada Noctalia
Greeter, pilih Mango sebelum login jika perlu kembali ke workflow tersebut.
Logout dahulu sebelum berpindah compositor; jangan menjalankan dua sesi native
untuk user yang sama sekaligus. Build tidak mengganti sesi yang sedang berjalan. Status build, aktivasi system,
aktivasi Home Manager, dan acceptance perangkat dicatat terpisah; kegagalan Home
Manager harus diselesaikan melalui [cutover berjurnal](cutover.md) sebelum menguji
shortcut baru dari HOME.

## Pemilik konfigurasi

| Perilaku | Sumber utama | Pemeriksaan |
| --- | --- | --- |
| Sesi sistem dan Noctalia Greeter | `modules/nixos/desktop.nix` | `system-features-independent`, build ThinkPad |
| Default sesi, monitor dan fitur perangkat | `hosts/nixos/thinkpad-x13/` | evaluasi host, login setelah reboot |
| Scrolling, shortcut dan aturan Umbriel | `modules/home-manager/desktop/umbriel/` | parser binary Umbriel yang terpin |
| Fallback Mango | `modules/home-manager/desktop/mango/` | parser Mango, login fallback |
| Screenshot/OCR/anotasi/rekaman | `modules/home-manager/programs/capture/` | `capture-workflow`, uji desktop nyata |
| Controller dan Yazi file chooser | `modules/home-manager/desktop/helpers.nix` | shell checks, file dialog |
| Warna/font/cursor | `themes/`, `modules/home-manager/appearance/` | theme checks, reload kedua desktop |

Katalog mendeklarasikan opsi tanpa mengaktifkan desktop. Host memilih
`dotfiles.desktop.umbriel.enable`, `mango.enable` dan `greeter.enable` secara
independen. NixOS mendaftarkan sesi dan layanan sistem; Home Manager mengelola
konfigurasi pengguna. Geometry output bukan default profil bersama. Modul
desktop Linux tidak diaktifkan oleh contoh macOS/Ubuntu/WSL CLI.

Paket Umbriel, portal dan greeter berasal dari pin Nixpkgs yang sama dan tersedia
di cache resmi saat implementasi. Tidak diperlukan input compositor tambahan.
Pin tersebut belum memiliki modul Home Manager Umbriel: adapter lokal memakai
`pkgs.formats.toml` dan memvalidasinya dengan binary yang sama dengan sesi.

## Shortcut dan screenshot

Pada ThinkPad, keyd memetakan tap Caps Lock ke Esc dan hold ke **Ctrl+Win+Alt**
(tanpa Shift). Modifier fisik yang sama dapat dipakai langsung. XKB lainnya
termasuk swap right Win/Ctrl tetap dipertahankan. Lepaskan Caps dan semua modifier
sebelum memakai aplikasi berikutnya; uji tap/hold ini pada perangkat setelah aktivasi.
Contoh Darwin/WSL CLI tidak mengaktifkan keyd.

Umbriel menetapkan `general.mod_key = "Super"` secara eksplisit agar `Mod`
berarti Win, sama dengan modifier SUPER pada Mango.

Sumber shortcut kedua compositor adalah `modules/home-manager/desktop/shortcuts.nix`.
**SuperKey = Ctrl+Win+Alt**:

| Shortcut | Perintah |
| --- | --- |
| SuperKey+3 | `shot screen` — seluruh desktop |
| SuperKey+Shift+3 | `shot output` — output aktif |
| SuperKey+4 | `shot area` |
| SuperKey+Shift+4 | `shot active` — jendela aktif |
| SuperKey+5 | `shot record toggle` — mulai output aktif / stop |
| SuperKey+Shift+5 | `shot record area` — pilih area / stop |
| SuperKey+S | `shelf-toggle` |
| SuperKey+C | `pick-color` — salin HEX |

**Win+Q** memerlukan dua penekanan dalam 600 ms pada jendela dan sesi yang sama.
Penekanan pertama memberi pengingat. Stream perubahan fokus membatalkan konfirmasi,
termasuk berpindah lalu kembali ke jendela awal. Close mengirim permintaan normal
ke ID jendela; tidak membunuh proses. Umbriel memakai `repeat = false`; Mango
memakai flag `bindn` dari patch terpin untuk menolak callback autorepeat.

`Print` tetap mempunyai jalur langsung berikut:

| Modifier | Perintah | Hasil |
| --- | --- | --- |
| Tidak ada | `shot area` | Pilih area, salin PNG |
| Ctrl | `shot screen` | Seluruh desktop, salin PNG |
| Alt | `shot active` | Bagian jendela aktif yang terlihat, salin PNG |
| Shift | `shot annotate` | Pilih area, edit dengan Satty, simpan dan salin |
| Super | `shot ocr` | Pilih area, salin teks Indonesia/Inggris |

Untuk screenshot biasa, notifikasi menawarkan Save, Decorate dan Quick Drag.
Save menyimpan ke direktori **Screenshots** di bawah direktori XDG Pictures;
fallback-nya `~/Pictures/Screenshots`. Direktori dibuat otomatis. Tidak memilih
Save tidak menyimpan screenshot clipboard ke galeri. Clipboard history dimiliki
Look; capture tidak menulis history lain. Escape saat memilih area membatalkan
capture tanpa mengganti clipboard.

`shot save-clip` menyimpan PNG dari clipboard. `shot record start|stop|status|toggle`
memakai **gpu-screen-recorder** sesuai pilihan pemilik. `area` memilih area pada
satu output; Escape membatalkan tanpa memulai recorder. Kedua binding menghentikan
rekaman aktif sebelum membuka selektor baru. Hasil MP4 H.264 60 fps berada di
**Recordings** di bawah XDG Videos, dengan encoder GPU dan fallback CPU saat startup.
Audio memakai monitor sink keluaran yang di-resolve lewat pactl; mikrofon tidak
dipilih. Tidak ada sumber monitor yang cocok berarti startup gagal.

Satu user service `dotfiles-record.service` memiliki proses recorder. Stop menunggu
SIGINT/finalisasi, memeriksa Result systemd dan stream/durasi MP4 dengan ffprobe;
kegagalan mempertahankan file parsial dan tidak memberi notifikasi berhasil.
Request privat dan lock berada di `$XDG_RUNTIME_DIR/dotfiles-record`. Scaling region
logis ditangani GSR; ukuran limit video dibuat genap, lalu encoder GSR melakukan
alignment. Validasi dimensi/file/audio perangkat tetap bagian acceptance.
NixOS mengaktifkan modul native GPU Screen Recorder untuk wrapper KMS; port Linux
non-NixOS memerlukan integrasi permission upstream yang setara.

Wrapper Nix memasang dependency pada PATH per perintah: grim, slurp, wl-clipboard,
Satty, ImageMagick, notifikasi, Tesseract bahasa `ind`/`eng`, dan recorder.
Tidak memerlukan instalasi alat atau unduhan model OCR manual.

`capture-window geometry|info|json|outputs|output|session|watch|close ID` memilih backend dari sesi aktif, bukan executable
yang ditemukan di PATH. Umbriel memakai IPC JSON dan memangkas jendela scrolling
ke output aktif; Mango memakai `mmsg`. Koordinat negatif dan fractional dibulatkan
keluar dalam koordinat logis untuk grim. `Super+P` menyalin identitas jendela.

## Shelf dan utilitas

Pluto Shelf 0.1.5 dipaketkan sebagai `pluto-shelf` dari wheel PyPI resmi dengan
hash tetap. Satu service `pluto-shelf.service` memakai nama D-Bus aplikasi;
`shelf-toggle` menunggu service siap lalu mengirim toggle ke instance tersebut.
File, folder, teks, URL dan gambar didukung oleh upstream. Edge strip kanan aktif;
`shake = false` karena deteksi shake upstream bergantung pada Hyprland.

Konfigurasi berada di `~/.config/pluto/config.toml`, palet/font mengikuti Stylix.
Pergantian tema merestart shelf aktif untuk membaca palet baru. State shelf dan
blob gambar tetap writable di `$XDG_DATA_HOME/pluto` (default `~/.local/share/pluto`).
Pembaruan lewat Nix; perintah installer Hyprland dan updater paket diblokir.

`pick-color` memakai hyprpicker untuk memilih pixel, memvalidasi HEX, lalu menyalin
teks dan memberi notifikasi. Escape atau hasil tidak valid mempertahankan clipboard.
Look tetap menangani clipboard/paste teks; gunakan mixer/caffeine Noctalia,
scratchpad terminal compositor, serta Espanso yang sudah ada.

## Sesi, portal dan appearance

Greeter menjalankan launcher paket `start-umbriel`; environment login dan unit
systemd mengikuti paket upstream. Noctalia dan Look dijalankan sebagai user
services, bukan proses kedua dari autostart. Portal dipilih per desktop: Umbriel
untuk ScreenCast/Screenshot Umbriel, wlr untuk Mango; Yazi tetap file chooser.

Stylix memasok palet kedua compositor. `dotfiles-theme set gruvbox-light` mengganti
varian pengguna yang sudah dibangun. Greeter memakai palet Gruvbox gelap dari
sumber tema bersama saat rebuild sistem; perubahan tema pengguna tidak mengubah
login screen sistem atau memerlukan aturan Polkit tanpa password.

PAM/fingerprint/keyring tetap dimiliki modul authentication. Submit password
kosong pada greeter memulai percakapan PAM fingerprint yang sudah dikonfigurasi;
itu bukan login tanpa autentikasi. Uji juga login password dan unlock keyring.
Rebuild tidak me-restart greetd; greeter baru diverifikasi setelah reboot manual.

## Troubleshooting dan acceptance

```sh
echo "$XDG_CURRENT_DESKTOP"
command -v nvim shot capture-window
capture-window geometry
shot area
systemctl --user status noctalia.service look.service pluto-shelf.service dotfiles-record.service
journalctl --user -b -u umbriel.service -u xdg-desktop-portal.service
systemctl status greetd home-manager-atalariq.service
```

Jika Neovim menampilkan `module 'conform' not found`, bandingkan executable aktif
dengan paket `nix run .#neovim`. Error yang direproduksi berasal dari executable
lama bersama symlink Lua baru. Migrasi HOME dan aktivasi profil menyelaraskannya;
mengunduh plugin dari Neovim bukan langkah recovery yang diperlukan.

Periksa screenshot asli pada Umbriel **dan** Mango: area, seluruh layar, jendela
aktif, clipboard PNG, Save, Decorate, Satty dan OCR. Uji scaling 1.25, serta layar
eksternal di kiri layar internal jika tersedia. Tes dengan mock membuktikan
routing dan penanganan kegagalan, bukan dukungan protokol desktop nyata.

Simpan backup privat dan generasi sebelumnya sampai login, portal/screen sharing,
capture, Neovim, audio dan suspend diterima. Lihat [recovery](installation.md),
[tema](themes.md), dan [bukti implementasi](artifacts/desktop-migration.md).

Referensi upstream: [Umbriel](https://docs.noctalia.dev/umbriel/),
[IPC](https://docs.noctalia.dev/umbriel/ipc/),
[Noctalia Greeter](https://docs.noctalia.dev/greeter/installation/).

Acceptance tambahan di **kedua sesi**: uji delapan shortcut SuperKey, Ctrl/Win/Alt
fisik, Caps tap/hold dan pelepasan modifier tanpa sticky keys. Uji Win+Q sekali,
dua kali, tahan Q, tunggu lewat 600 ms, pindah fokus, serta pindah fokus lalu kembali.
Uji recording output/area, Escape, stop saat selektor berikutnya dibatalkan, playback
MP4, suara sistem dan tidak ada mikrofon; periksa ukuran genap lewat ffprobe.
Uji shelf drag-in/out file/folder/teks/link/gambar browser, edge trigger, toggle,
restart/persistence, dan color picker/cancel tanpa mengubah clipboard.
