# Progress 1 — Individual Assignment 7 (Basic Flutter)

- Tanggal eksekusi: 13 November 2026
- Checkpoint: 1 dari 3 — Identitas + Baseline
- Proyek: `myportofolio_mobile`
- Branch: `main` (melacak `origin/main`)

## Sumber dan Baseline

- PDF resmi: `/Users/devanmacbook/Documents/01_Kuliah/MAIN_KULIAH/Semester-3/PBP/Tugas-Individu/tugas-7.pdf` (5 halaman).
  Teks diekstrak dengan `pdftotext -layout` karena model tidak mendukung input PDF langsung.
- Commit prasyarat Tutorial 08: `9783fb4 feat(flutter): complete PBP tutorial 08 basic portfolio`.
- Working tree bersih sebelum perubahan.
- Baseline: `flutter analyze` tanpa isu; `flutter test` 6 test lulus.
- Environment: Flutter 3.47.9, Dart 3.13.7, Chrome 157, Android SDK 36 dengan lisensi diterima.

## Perubahan Checkpoint 1

| File | Perubahan |
|---|---|
| `lib/menu.dart` | Data contoh Burhan diganti identitas personal: NPM `2506614712`, nama `Glenn Josia Devano`, kelas `PBP F`. Konten `ItemCard` dibungkus `FittedBox(scaleDown)` agar label tidak overflow pada layar sempit; teks tetap ukuran natural bila muat. |
| `test/widget_test.dart` | Assertion identitas personal; verifikasi data Burhan absen; verifikasi `MyHomePage` tetap `StatelessWidget`; regression test viewport 320x640 tanpa exception. |
| `docs/tugas-7/PROGRESS_1.md` | Catatan progres ini. |

Tidak ada perubahan pada `lib/main.dart`, tema, model menu, warna kartu, atau README.

## Perilaku Sebelum dan Sesudah

- Sebelum: tiga InfoCard menampilkan `2406000001` / `Burhan` / `PBP A`.
- Sesudah: tiga InfoCard menampilkan `2506614712` / `Glenn Josia Devano` / `PBP F`.
- Struktur tiga InfoCard, tiga ItemCard, SnackBar, dan AppBar tidak berubah.

## Verifikasi

```text
dart format lib test  : bersih
flutter analyze       : No issues found!
flutter test          : 8 test lulus
flutter build web     : berhasil
```

Runtime browser diuji pada viewport 320x640, 390x844, dan 1280x800: identitas tampil
lengkap, tidak ada overflow maupun error console. SnackBar ketiga menu tetap berfungsi.

## Risiko dan Catatan

- README masih menjelaskan data contoh Tutorial 08 (Burhan) dan belum memuat jawaban
  refleksi; pembaruan dijadwalkan pada Checkpoint 3.
- Warna kartu aksi masih amber seragam; kustomisasi warna dijadwalkan pada Checkpoint 2.
- Nama panjang membuat kartu Name lebih tinggi pada layar sempit, tetapi teks tetap utuh
  dan tidak terpotong.
- Xcode/iOS tetap belum terverifikasi (warning environment lama, bukan regresi).

## Rekomendasi Commit Manual

```text
feat(flutter): personalize portfolio identity for assignment 7
```

File yang disarankan untuk di-stage: `lib/menu.dart`, `test/widget_test.dart`,
`docs/tugas-7/PROGRESS_1.md`.
