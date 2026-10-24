# Daya dan beban berat ThinkPad

Target ini khusus ThinkPad X13 AMD; profil Ubuntu/macOS tidak mengubah power
manager sistem operasi. TLP dan tlp-pd menggantikan power-profiles-daemon.

| Profil | Default | EPP | CPU boost |
| --- | --- | --- | --- |
| power-saver | Baterai | power | Mati |
| balanced | Charger | balance_performance | Aktif |
| performance | Permintaan pengguna/aplikasi | performance | Aktif |

Governor tetap `powersave` pada amd-pstate-epp. Nama tersebut tidak berarti CPU
terkunci di frekuensi minimum: EPP dan workload menentukan respons. Dalam TLP
modern suffix `_AC`, `_BAT`, `_SAV` berarti profil performance/balanced/saver.
Threshold pengisian, thermal limit vendor, zram, encrypted swap dan TRIM dipertahankan.

```sh
just power balanced
just power power-saver
tlpctl get
tlpctl list-holds
dotfiles-boost ./gradlew assembleDebug --max-workers=4
just build-fast thinkpad-x13
```

Hold performance berakhir bersama perintah. Gunakan executable foreground yang
benar; aplikasi yang langsung daemonize bisa membuat hold berakhir terlalu awal.
Pemilihan profil manual melalui panel/tlpctl dapat melepas hold yang ada.

## Gaming

Pada launch options Steam untuk game tertentu:

```text
dotfiles-boost mangohud %command%
```

MangoHud tidak aktif untuk seluruh sesi. Bila ingin menghemat GPU pada layar
60 Hz, coba per game `MANGOHUD_CONFIG=fps_limit=60 dotfiles-boost mangohud %command%`.
Jangan mengukur FPS dengan cap tersebut lalu membandingkannya dengan run tanpa cap.
CPU dan iGPU berbagi anggaran daya: bandingkan balanced dan performance dengan
resolusi, scene, durasi, kondisi charger dan temperatur awal yang sama. Catat
frametime, suhu serta beban, bukan hanya FPS rata-rata. Tidak ada overclock atau
GPU clock yang dipaksakan global.

## Android dan Gradle

Utamakan perangkat fisik. Pasang SDK writable melalui Android Studio, terima
lisensi yang diperlukan secara manual, aktifkan USB debugging dan setujui dialog
otorisasi perangkat. Systemd pada pin ini menyediakan uaccess; opsi NixOS ADB
lama sudah dihapus. Gunakan `adb devices` dan `scrcpy` setelah login ulang.

Konfigurasikan Gradle per proyek: misalnya empat worker, heap 3 GiB, daemon
dan build cache. Sesuaikan anggaran dengan kebutuhan proyek dan RAM yang tersedia. Gradle Wrapper dan versi JDK mengikuti kebutuhan Android Gradle Plugin;
configuration cache baru diaktifkan setelah kompatibilitas plugin diperiksa.
Jangan membuat `JAVA_TOOL_OPTIONS` global untuk semua IDE dan LSP.

Emulator tetap opsional: cek `emulator -accel-check`, gunakan image yang sesuai
arsitektur host, satu AVD dengan KVM/GPU acceleration, dan anggaran RAM terbatas.
Tidak ada AVD atau SDK yang diunduh ketika memasuki devshell.

## Pengukuran dan acceptance

Sebelum/sesudah aktivasi, gunakan workload yang sama dan catat profile/EPP,
konsumsi baterai idle, responsiveness IDE, warm build Gradle, temperatur dan
memory pressure. Uji cabut/pasang charger, suspend/resume, audio USB dan ADB.
Gunakan profiler daya on-demand; jangan menjalankan auto-tune tambahan bersamaan
TLP. Hasil build konfigurasi bukan bukti penghematan baterai.
