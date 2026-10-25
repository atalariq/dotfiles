# Cutover desktop yang dapat dipulihkan

Bangun dan validasi checkout sebelum menyentuh HOME. Jalankan `nix flake check`,
`nix flake check --all-systems --no-build`, dan `just desktop-smoke`. Smoke test
memakai dependency dari pin flake, HOME/socket Wayland/D-Bus privat, serta kedua
compositor nyata. Tes mencakup clipboard PNG, pelepasan modifier, autorepeat,
konfirmasi tutup, dan penyimpanan shelf saat berhenti. Fixture Mango memakai
keysym untuk keymap virtual wtype; binding harian memakai kode tombol compositor.
Caps/keyd fisik, audio monitor dan encoder perangkat tetap diuji setelah aktivasi.

Mango memakai patch kecil `packages/mango-norepeat.patch` pada source pin yang
sama. Flag `bindn` menolak callback repeat untuk aksi sekali tekan tanpa mengubah
repeat binding navigasi biasa. Paket ini dibangun lokal; pin/cache lain dipertahankan.
Recording tetap menggunakan GPU Screen Recorder sesuai keputusan pengguna.

## Persiapan privat

Setelah membangun system dan Home Manager, gunakan output store sebenarnya:

```sh
nix run .#dotfiles-cutover -- prepare thinkpad-x13 /nix/store/...-nixos-system-thinkpad-x13-... /nix/store/...-home-manager-generation
nix run .#dotfiles-cutover -- status /path/transaction.XXXXXXXX
```

Prepare tidak memindahkan HOME. Ia memverifikasi output terhadap snapshot source
immutable, mengaudit konflik, membandingkan backup link dan isi efektif, menyimpan
checksum manifest, serta memasang enam GC root: source/system/HOME baru dan
system running/booted/profile sebelumnya. State privat berada di
`$XDG_STATE_HOME/dotfiles/cutover` (default `~/.local/state`). Simpan backup lama.
State harus berada pada filesystem yang sama dengan semua target; pemindahan
lintas filesystem ditolak. `mv --no-copy` menjamin tidak beralih ke copy/unlink.

## Aktivasi di terminal pemilik

Review manifest privat dan siapkan terminal pemulihan. Untuk handoff recovery yang
sudah disiapkan, pemilik cukup menjalankan satu command lokal:

```sh
bash /path/transaction.XXXXXXXX/run-activation.sh
```

Handoff memuat helper teruji dari Nix store serta tool cutover yang dipertahankan
sebagai GC root tambahan. Helper sumbernya `lib/activate-owner.sh STATE CUTOVER_COMMAND`.
Urutannya: periksa transaksi, autentikasi `sudo -v`, relocate dengan audit ulang,
lalu switch ke snapshot immutable. `sudo -n` setelah relocation menjamin tidak ada
prompt password ketika HOME sedang dipindahkan. Kegagalan switch atau verifikasi
memanggil rollback HOME dan mempertahankan log privat. Kegagalan relocation
menggunakan rollback internal cutover; switch tidak dijalankan.

Jangan menjalankan switch terpisah sebelum relocation. Pada recovery 25 Oktober,
system baru sempat aktif sedangkan transaksi masih prepared dan jurnal kosong;
Home Manager menolak file lama dengan pesan “would be clobbered”. Backup, audit,
dan arsip saat diagnosis tetap cocok. Ini adalah migrasi HOME yang belum selesai.

Keberhasilan diperiksa melalui hasil service Home Manager, root generasi HOME,
system aktif, system profile, dan checksum Codex pribadi bila manifest tersedia.
`activation-result.json` merekam hasil ini secara terpisah dari status transaksi
`relocated`; `owner-switch.log` menyimpan output switch tanpa prompt password.
Sukses build atau status relocated saja tidak membuktikan aktivasi berhasil.

Jika proses terkena SIGKILL setelah relocation, periksa jurnal dan gunakan tool
cutover terpin untuk `rollback STATE` sebelum retry. Jangan mengulang command pada
transaksi yang sudah relocated/restored tanpa pemeriksaan. Jika inventory berubah,
siapkan transaksi baru; jangan mengedit checksum atau melemahkan pemeriksaan.

Rollback memulihkan identitas asli dan hanya menyingkirkan link generasi baru yang
dikenali. Data pengguna baru yang tidak dikenal menyebabkan `rollback-blocked`;
kedua salinan dipertahankan untuk review manual. Jangan hapus jurnal/backup.
Rollback HOME terpisah dari rollback system. Gunakan generasi boot yang diketahui
bekerja atau root `recovery-running`; root profile dapat berbeda dari system yang
sedang berjalan. Baseline HOME yang dipulihkan dapat memiliki kegagalan lama.

Reboot tetap manual. Selesaikan acceptance kedua sesi di [desktop](desktop.md)
sebelum commit, menghapus backup, atau melepaskan root pemulihan. Evaluasi ARM
atau Darwin pada host x86 bukan bukti build/runtime platform tersebut.

## Review independen

Untuk second opinion, mulai agent dengan konteks kosong dan hanya berikan lokasi
source serta mandat review. Jangan kirim riwayat percakapan, temuan sebelumnya,
memori, atau hasil validasi lokal. Verifikasi sendiri temuan konkret dan tambahkan
tes regresi sebelum menganggapnya selesai.

Handoff memegang lock transaksi sepanjang autentikasi, relocation, switch dan
verifikasi. Child cutover memakai descriptor lock warisan yang identitasnya
diperiksa; command rollback terpisah ditolak selama handoff masih berjalan.
Gunakan pasangan helper/tool immutable dari handoff yang sama. Kegagalan menulis
catatan hasil tidak menghentikan percobaan rollback; bila rollback sendiri gagal,
helper melaporkannya dan mempertahankan jurnal untuk recovery manual.

Inventory diurutkan dengan locale C secara eksplisit agar terminal dengan locale
berbeda menghasilkan byte yang sama. Jika guard masih melaporkan perubahan,
periksa perbedaan path dan siapkan backup transaksi baru dari kondisi sekarang;
jangan menjalankan switch secara terpisah untuk melewati penolakan relocation.
