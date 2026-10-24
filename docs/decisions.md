# Keputusan arsitektur

## Program alfabetis, profil berdasarkan workflow

Kategori aplikasi sering bertumpang tindih: editor digunakan di terminal maupun
development, sedangkan rsync tidak khusus keamanan. Program disusun alfabetis;
profil menyusun pilihan CLI, development, GUI, creative dan gaming. Paket biasa
tidak mendapat wrapper enable yang hanya menambah pekerjaan pemeliharaan.

## Home Manager upstream sebagai interface pertama

Konfigurasi terstruktur dihasilkan lewat `programs.*`. Ini mengurangi duplikasi
parser, pengelolaan file dan hook shell. Opsi khusus tersisa untuk perilaku yang
belum tersedia upstream. Fungsi/skrip kompleks tetap berupa kode bahasa native,
bukan ditransliterasi menjadi ekspresi Nix. Tmux dan Vim tetap bisa disalin ke
server tanpa Nix.

## Flake-parts dan registry host

`perSystem` mengelola build products untuk Linux x86/ARM dan macOS ARM. Registry
host menghasilkan keluarga output sesuai OS tanpa menyalin konstruksi flake.
Hardware dan identitas tidak masuk profil bersama. Mac Intel tidak dipaksakan
ke Nixpkgs 26.11 yang sudah menghapus dukungannya.

## Just dan nh

Just adalah command runner; Nix tetap memiliki dependency graph build. Recipe
meneruskan argumen ke shell tipis dan nh. Target host eksplisit menghindari
pemilihan instalasi berdasarkan hostname mesin yang menjalankan build. Apply
memeriksa platform, jenis instalasi dan identitas sebelum menyerahkan aktivasi
kepada nh. Clean bersifat preview; eksekusi terpisah mempertahankan root manual.

## Satu pemilik appearance dan clipboard

Stylix memiliki warna/font. Target upstream digunakan bila tersedia dalam pin;
adapter khusus menghubungkan Mango, Noctalia, Look, Herdr dan Fastfetch. Look
memiliki launcher serta clipboard; collector Noctalia dan cliphist lama tidak
berjalan bersamaan. Noctalia tetap mengelola panel, notifikasi dan lockscreen.

## TLP dan performa sementara

TLP 1.10.2 memiliki tiga profil yang dapat dipilih independen dari charger.
Tlp-pd menyediakan D-Bus untuk desktop, sehingga menggantikan daemon PPD lama.
AC default balanced, baterai power-saver. Profile hold meminta performance
selama game/perintah berjalan dan dilepas setelah selesai. Tidak ada overclock,
perubahan thermal limit, pemaksaan frekuensi maksimum, atau janji peningkatan FPS.

Build Nix biasa dibatasi 2 pekerjaan × 2 core. Build cepat memakai 1 × 8 untuk
menghindari banyak compiler memory-heavy bersamaan. Android mengutamakan device
fisik, scrcpy dan tuning Gradle per proyek, bukan JVM flags global.

## State, secrets dan recovery

SOPS membaca kredensial saat runtime; identitas privat tidak masuk Git/store.
SDK, akun aplikasi, project dan pairing perangkat tetap writable. Generasi Nix
membantu rollback konfigurasi, tetapi backup data tetap pekerjaan terpisah.
Disko, impermanence dan migrasi disk tidak diperlukan dalam revisi ini.
