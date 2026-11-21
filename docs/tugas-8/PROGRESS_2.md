# Tugas 8 — Checkpoint 2

## Ringkasan

Form Sertifikasi kini memvalidasi enam isian. Tombol **Simpan** membuka
ringkasan setelah semua isian valid. Tombol **Tutup** kembali ke formulir
sambil mempertahankan isian. QC browser lulus. Seluruh 33 widget test lulus di Terminal macOS.

## Sumber dan baseline

- Empat halaman PDF Tugas 8, megaprompt Checkpoint 2, `PROGRESS_1.md`,
  diff Checkpoint 1, dan suite Tugas 7 sampai Tutorial 09 ditinjau.
- Working tree awal bersih. `HEAD` dan ref lokal `origin/main` sama-sama
  menunjuk `4c795efc57038db0b4de2676484a6f6ec2988f71`. Output `git ls-remote`
  dari terminal pengguna menunjukkan SHA yang sama. Cek ulang SSH dari
  sesi Codex terhalang resolusi DNS `ssh.github.com`.
- Remote `git@github.com:glennjosia7/myportofolio_mobile.git`, branch `main`,
  author dan committer `DevCoder-7 <177463070+DevCoder-7@users.noreply.github.com>`.
- Tutorial 09 berada di `53ba8df`. Reflog mencatat push pada 17 November
  2026 pukul 20.26 WIB, sebelum tenggat prasyarat 18 November 2026 pukul
  23.59 WIB.
- Uji ulang baseline dengan Flutter 3.47.9 dan Dart 3.13.7 menghasilkan
  format, analyzer, dan build web lulus. Runner gagal sebelum 24 test
  baseline berjalan.

## Keputusan validasi

| Input | Aturan |
|---|---|
| Nama Sertifikasi, Lembaga Penerbit, ID Kredensial | Wajib setelah trim, maksimal 255 karakter Unicode per isian |
| URL Kredensial | Wajib setelah trim, maksimal 200 karakter. Perlu skema HTTP atau HTTPS dan host yang terurai. Spasi internal, backslash, dan escape persen rusak ditolak. |
| Tanggal Terbit | Wajib dipilih melalui `showDatePicker()` |
| Tanggal Kedaluwarsa | Opsional, dapat dikosongkan kembali, dan jika diisi harus sama dengan atau setelah tanggal terbit. |

`Certification` di `myportofolio/main/models.py` menetapkan `URLField()`
sebagai field wajib. Ketentuan PDF untuk mengikuti model digunakan untuk
menyelesaikan perbedaan dengan saran URL opsional di megaprompt. Batas
200 karakter mengikuti default `URLField`. Validasi URL dilakukan lokal
terhadap format. Form dan dialog dapat digulir. Form dibatasi 560 piksel
logis di layar lebar. Ringkasan memakai format tanggal lokal dengan tahun,
dan menampilkan **Tidak diisi** bila tanggal kedaluwarsa kosong.

## Pemetaan PDF dan bukti pengujian

| Persyaratan | Status | Bukti |
|---|---|---|
| Form stateful dan kontrol sesuai tipe data, hlm. 1 | Lulus di Zen | Form key, empat `TextFormField` dan dua `FormField<DateTime>` |
| Validasi per field dan dialog ringkasan, hlm. 2 | Lulus di Zen | Test isian kosong/whitespace, panjang, URL, urutan tanggal, enam nilai, Tutup, dan hapus tanggal opsional |
| Kartu, drawer, Home dan Back, hlm. 2 | Lulus di Zen | Kasus navigasi CP1 dipertahankan. Test kartu diperbarui untuk keenam kontrol. |
| Form dan Simpan terjangkau, hlm. 2 | Lulus di Zen tanpa simulasi papan ketik | Kasus 320×640, 390×844, 768×1024 dan 1280×800. Kasus 320×640 menyimulasikan papan ketik 280 piksel. |
| Regresi Tugas 7 dan Tutorial 09 | Widget test regresi berjalan di Terminal | Test identitas, warna, SnackBar, navigasi dan form proyek dipertahankan. |
| Analyzer dan pemeriksaan diff, hlm. 2 | Lulus | Hasil perintah di bawah |
| Refleksi README dan AI disclosure, hlm. 2–3 | Checkpoint 3 | Menunggu trigger `LANJUT CHECKPOINT 3` setelah CP2 dipush |
| Commit dan push CP2, hlm. 2–3 | Menunggu quality gate dan izin | Usulan commit `feat(flutter): validate certification input and show summary dialog` |

| Perintah | Hasil pada Checkpoint 2 |
|---|---|
| `flutter pub get --offline` | Lulus memakai cache, lockfile tidak berubah |
| `dart format --output=none --set-exit-if-changed lib test` | Lulus, delapan file sudah terformat |
| `flutter analyze --no-pub` | Lulus, `No issues found!` |
| `flutter test --no-pub --reporter expanded` | Runner Codex terblokir oleh izin soket localhost. Terminal macOS menjalankan 33 test. Hasil setelah koreksi terakhir: 33/33 lulus, termasuk simulasi papan ketik di 320×640. |
| `flutter build web --no-pub` | Lulus, `Built build/web` |
| `git diff --check` | Lulus |

QC Zen pada build rilis lokal lulus untuk navigasi kartu, drawer, Home,
dan Back. Validasi isian wajib, URL, dan urutan tanggal lulus. Dialog
menampilkan enam nilai, mempertahankan isian ketika ditutup, dan
menerima tanggal kedaluwarsa yang dikosongkan. Tombol Simpan bisa ditekan
pada 320×640, 390×844, 768×1024, dan 1280×800 tanpa simulasi papan ketik.
Form Tambah Proyek masih dapat dibuka.

Test 320×640 kini menunggu SnackBar navigasi selesai sebelum simulasi
papan ketik, lalu menggulir ke tombol dan mengetuknya dengan inset masih
aktif. Seluruh suite lulus saat dijalankan ulang di Terminal macOS.
Refleksi README, AI disclosure, dan laporan akhir masuk Checkpoint 3.

## Status Git

Perubahan CP2 mencakup `lib/screens/certification_form.dart`,
`test/widget_test.dart`, `test/certification_form_test.dart`, dan laporan ini.
Seluruh perubahan CP2 berada di working tree. Seluruh quality gate CP2 lulus sebelum commit.
