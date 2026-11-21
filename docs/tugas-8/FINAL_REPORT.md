# Laporan Akhir Tugas Individu 8

Glenn Josia Devano · NPM 2506614712 · PBP F · CSGE602022

## Ringkasan

Tugas 8 menambahkan Form Sertifikasi dengan enam isian, akses dari kartu dan
`LeftDrawer`, validasi per isian, serta `AlertDialog` berisi ringkasan. CP3
menyelesaikan empat refleksi, pengungkapan penggunaan AI, dan audit akhir.
Pada CP3, 33/33 widget test lulus di Terminal macOS dan QA Zen lulus pada empat viewport.

## Pemetaan persyaratan

| PDF | Persyaratan | Status | Bukti |
|---|---|---|---|
| Hlm. 1–2 | Form relevan, stateful, dan minimal tiga input sesuai model | PASS | `CertificationFormPage`, `GlobalKey<FormState>`, empat input teks, dan dua pemilih tanggal |
| Hlm. 2 | Akses dari kartu dan drawer dengan alur kembali | PASS pada CP2 | Widget test dan QA Zen mencakup kartu, drawer, Home, dan Back |
| Hlm. 2 | Validasi per isian dan dialog berisi semua nilai | PASS pada CP2 | Test isian kosong atau spasi, panjang, URL, urutan tanggal, dialog enam nilai, dan tombol Tutup |
| Hlm. 2 | Form dan Simpan terjangkau pada layar sempit | PASS pada CP2 | Empat viewport di Zen. Widget test 320×640 memakai inset papan ketik 280 piksel |
| Hlm. 2 | Regresi, analyzer, dan build web | PASS pada CP3 | Analyzer dan build web lulus. Seluruh 33 widget test lulus di Terminal macOS. |
| Hlm. 3 | Empat refleksi dalam `### Tugas 8` dan tautan commit | PARTIAL | Keempat refleksi tersedia di README. Tautan final menunggu commit dan push |
| Hlm. 4 | AI disclosure faktual | PASS | Bagian Tugas 8 di README mencatat alat, arahan prompt, keterbatasan, dan koreksi pengujian |

URL kredensial wajib sesuai model Django dan menerima HTTP atau HTTPS.
Tanggal kedaluwarsa boleh kosong atau sama dengan tanggal terbit. Tombol
Tutup mempertahankan isian. Dialog menampilkan data lokal sementara.

## Bukti pengujian

Flutter 3.47.9 dan Dart 3.13.7. Referensi hasil runtime terdahulu adalah
[PROGRESS_2.md](PROGRESS_2.md). `lib/`, `test/`, `web/`, `pubspec.yaml`, dan
`pubspec.lock` identik dengan CP2. CP3 mengubah dokumentasi saja.

| Pemeriksaan | Hasil | Bukti |
|---|---|---|
| `flutter pub get --offline` | PASS | Resolusi dari cache, lockfile tetap |
| `dart format --output=none --set-exit-if-changed lib test` | PASS | 8 file, 0 perubahan |
| `flutter analyze --no-pub` | PASS | `No issues found!` |
| `flutter build web --no-pub` | PASS | `Built build/web` |
| `flutter test --no-pub --reporter expanded` | PASS | 33/33 lulus di Terminal macOS. |
| Browser QA | PASS pada CP3 | Zen memverifikasi kartu, drawer, Home, validasi isian kosong, pemilih tanggal, dialog ringkasan, dan form proyek. Simpan bisa ditekan pada 320×640, 390×844, 768×1024, dan 1280×800. |
| Aksesibilitas dan console browser | Verifikasi terbatas | Cek sumber mencakup label isian, tombol kalender, tooltip hapus tanggal, fokus, dan kontras teks putih pada kartu sertifikasi. Console browser dan navigasi keyboard belum diperiksa ulang di CP3. |
| Android/iOS native | Belum diuji | Target pengujian Tugas 8 adalah Flutter Web |

Regresi suite mencakup identitas Tugas 7, tiga warna dan SnackBar awal,
navigasi Tutorial 09, lima isian proyek, validasi, dialog, dan reset form.

## Bukti per rubrik

| Rubrik | Bobot | Bukti |
|---|---|---|
| Fungsionalitas dan kesesuaian topik | 70% | Enam isian, navigasi, validasi, ringkasan, pengosongan tanggal opsional, dan uji viewport |
| Kualitas dan struktur kode | 10% | Folder `screens/` dan `widgets/`, penggunaan ulang drawer dan kartu, analyzer bersih |
| Git dan disiplin | 10% | Commit terpisah untuk fondasi dan validasi, dokumentasi akhir disiapkan sebagai CP3 |
| Dokumentasi, AI disclosure, dan refleksi | 10% | Empat jawaban di README, cara menjalankan proyek, disclosure, laporan progres, dan bukti QA |

## Audit Git dan file sensitif

| Tahap | Commit | Status |
|---|---|---|
| Tutorial 09 | [`53ba8df`](https://github.com/glennjosia7/myportofolio_mobile/commit/53ba8df25863601d6aa81501cae8579747f2ab0b) | Reflog mencatat push 17 November 2026 pukul 20.26 WIB, sebelum tenggat prasyarat |
| CP1 | [`4c795ef`](https://github.com/glennjosia7/myportofolio_mobile/commit/4c795efc57038db0b4de2676484a6f6ec2988f71) | Leluhur `origin/main`. Push tercatat 20 November 2026 pukul 22.42 WIB |
| CP2 | [`e0e73e8`](https://github.com/glennjosia7/myportofolio_mobile/commit/e0e73e83ee190928b9094c027cb45f0ecb6cbe28) | `HEAD` dan ref lokal `origin/main` sama. Push tercatat 21 November 2026 pukul 23.50 WIB |
| CP3 | Menunggu SHA | `docs(flutter): finalize assignment 8 reflections and verification` |

Working tree awal bersih, `main` melacak `origin/main`, dan identitas Git
adalah `DevCoder-7`. Verifikasi langsung ke GitHub masih terhalang DNS SSH
dan akses HTTPS dari sesi ini. Perubahan CP3 mencakup `README.md` dan laporan
ini. Index bersih. Pemeriksaan diff, nama berkas, dan pola kredensial umum
selesai tanpa temuan pada cakupan perubahan Tugas 8. `android/local.properties`,
`build/`, dan `.dart_tool/` tercakup oleh aturan ignore. Manifest dependensi
dan lockfile sama dengan baseline Tutorial 09.

## Penyelesaian pengumpulan

Quality gate CP3 lulus dan commit serta push telah disetujui. Stage `README.md` dan `docs/tugas-8/FINAL_REPORT.md`, periksa diff
staged, buat satu commit CP3, lalu push `origin main`. Cocokkan SHA lokal dengan
`refs/heads/main` di GitHub dan gunakan URL halaman commit final untuk SCELE.
Tenggat Tugas 8 adalah **23 November 2026 pukul 23.59 WIB**.
