# Instalasi dan recovery

## Add a host

1. Tambahkan entry pada registry host: jenis `nixos`, `darwin`, `home` atau `wsl`,
   arsitektur, username serta HOME atau modul host yang sesuai.
2. Pilih profil bersama. CLI/development tidak membutuhkan desktop NixOS.
   Contoh memakai user `example`; ganti identitas sebelum menjalankan apply.
3. Untuk NixOS, gunakan hardware hasil scan mesin sendiri. Pertahankan
   `system.stateVersion` dan `home.stateVersion` instalasi lama.
4. Tambahkan sumber publik baru ke Git, jalankan `just check`, lalu `just build nama-host`.
5. Audit target HOME, backup konflik secara privat, dan review perubahan paket
   dengan `just diff nama-host` sebelum `just apply nama-host`.

Flake menghasilkan keluarganya otomatis dari registry. Tambahan host tidak
memerlukan salinan konstruksi nixosSystem/darwinSystem/Home Manager.

## Pilih jenis instalasi

- **NixOS:** output `nixosConfigurations`, termasuk ThinkPad yang ada. Driver,
  login manager, firewall, audio dan power management dikelola modul NixOS.
- **macOS Apple Silicon:** output `darwinConfigurations.macos-example`. Home
  Manager diintegrasikan lewat nix-darwin. Adaptasi user dan stateVersion dahulu;
  bootstrap nix-darwin mengikuti petunjuk upstream bila belum terpasang.
- **Ubuntu/distro lain:** output `homeConfigurations.ubuntu-x86_64-linux` atau
  `ubuntu-aarch64-linux`. `targets.genericLinux` menyediakan integrasi HM yang
  relevan. Driver GPU, login shell sistem dan layanan OS tetap dimiliki distro.
  Aplikasi GUI Nix mungkin memerlukan setup GPU generic-Linux/nixGL sesuai driver.
- **Ubuntu WSL:** memakai Nix/Home Manager di distro yang sudah ada; tidak mengganti
  Ubuntu menjadi NixOS. CLI menjadi default. GUI memerlukan WSLg; Podman rootless
  memerlukan dukungan kernel dan user services/systemd dari distro WSL.
- **NixOS-WSL:** contoh sistem terpisah memakai modul upstream NixOS-WSL. Instal atau
  impor distribusi WSL sesuai dokumentasi upstream, lalu adaptasi registry sebelum
  switch. Jangan menerapkannya pada ThinkPad native.

Nix tidak men-cross-build macOS hanya dengan mengekspor output Darwin. Gunakan
runner native yang sesuai untuk build/runtime acceptance. Tidak ada dukungan
Mac Intel melalui pengabaian metadata platform.

## Build dan apply

```sh
nix develop
just build ubuntu-x86_64-linux
just build thinkpad-x13
just diff thinkpad-x13
# Setelah konfigurasi dan konflik diperiksa:
just apply thinkpad-x13
```

Just memakai selector host/configuration nh, bukan menebak nama dari mesin yang
menjalankan build. Apply menolak platform/identitas yang berbeda. NixOS system
apply membutuhkan NixOS, dan target WSL membutuhkan lingkungan WSL.

## HOME conflicts and source migration

Backup file yang akan digantikan di direktori privat di luar Git. Periksa linked
parent directory, bukan hanya leaf: `.config/mango/script` dan direktori aplikasi
lain dapat menunjuk langsung ke checkout. Jangan menulis file melalui link tersebut
karena itu juga mengubah sumber repo. File runtime yang tidak dikelola dipertahankan.

Mode immutable mengikuti generasi; mode live hanya berlaku pada sumber native
yang memakai helper. Perubahan file live tidak dapat dibatalkan oleh rollback
profile. Build terlebih dahulu, lalu lakukan aktivasi dengan autentikasi lokal.

Sebelum apply ThinkPad, jalankan audit read-only terhadap generasi yang baru
dibangun: `sh lib/audit-home.sh /nix/store/...-home-manager-generation`. Inventaris
menampilkan leaf, symlink induk, dan link Neovim lama yang tidak lagi dimiliki
manifest nvf. Salin konflik beserta isi targetnya ke backup privat; jangan
menghapus direktori writable atau menyimpan inventaris privat di Git.

Selesaikan migrasi HOME, review diff, lalu lakukan aktivasi dengan sudo lokal
dan reboot manual setelah pekerjaan tersimpan. Noctalia Greeter menawarkan
Umbriel sebagai default dan Mango sebagai fallback. Uji [kedua desktop dan
screenshot](desktop.md) sebelum menghapus backup.

## Recovery

Pertahankan generasi yang sudah bekerja dan backup sampai login, autentikasi,
portal, audio, suspend dan aplikasi penting diterima. Gunakan pilihan generasi
boot NixOS atau aktivasi ulang generasi Home Manager yang diketahui bekerja.

`just clean` adalah preview. `clean-apply` membersihkan user profile dengan
retensi minimal lima generasi dan 30 hari, tanpa menghapus root manual/direnv.
Tidak ada cleanup terjadwal, penghapusan backup migrasi, atau migrasi disk.

Provisioning age identity, akun aplikasi, SDK license dan trust perangkat tetap
manual. Baca [secrets](secrets.md), [power/performance](performance.md), dan
[catatan validasi](artifacts/validation.md) sebelum acceptance host.

Untuk lanjutan SuperKey, audit/backup terbaru dicatat di
[artefak desktop](artifacts/desktop-migration.md). Backup menyimpan arsip symlink
serta arsip isi efektif secara terpisah; checksum harus cocok sebelum cutover.
Periksa `targets.list` dan `home-audit.tsv` privat. Ekstrak arsip isi efektif ke
direktori pemulihan kosong untuk dibandingkan; jangan mengekstrak langsung di
atas symlink konfigurasi yang aktif. Setelah persetujuan, pindahkan hanya konflik
HOME yang sudah ditinjau, lalu jalankan switch dengan autentikasi sudo lokal.
Generasi dan backup tetap disimpan sampai acceptance kedua sesi selesai.

Alur cutover baru menggunakan backup, GC root dan jurnal transaksi privat;
lihat [panduan cutover](cutover.md). Gunakan command aktivasi dari snapshot
immutable yang dicetak tool, menggantikan handoff checkout mutable di atas.
