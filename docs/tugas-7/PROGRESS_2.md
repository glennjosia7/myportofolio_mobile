# Individual Assignment 7 — Progress 2

- Tanggal eksekusi: 14 November 2026
- Checkpoint: 2 dari 3 — Warna ItemCard dan Aksesibilitas
- Branch: `main`
- Proyek: `myportofolio_mobile`

## 1. Ringkasan Progress 1

Checkpoint 1 mengganti identitas contoh Tutorial 08 dengan identitas personal
(`Glenn Josia Devano`, NPM `2506614712`, kelas `PBP F`), menambahkan regression test
identitas dan viewport 320x640, serta membuat `docs/tugas-7/PROGRESS_1.md`.
Checkpoint 1 sudah di-commit dan di-push manual oleh pengguna dengan pesan
`feat(flutter): personalize portfolio identity for assignment 7`.

## 2. Baseline dan Git Checkpoint

- Commit Tutorial 08: `9783fb4`.
- Commit Checkpoint 1: `eb96955`.
- Working tree bersih sebelum Checkpoint 2.
- Branch `main` melacak `origin/main`; remote `git@github.com:glennjosia7/myportofolio_mobile.git`.
- Baseline yang diverifikasi ulang: `flutter analyze` bersih, `flutter test` 8 test lulus.
- PDF resmi `tugas-7.pdf` (5 halaman) dibaca sebagai teks melalui `pdftotext` karena
  model tidak mendukung input PDF langsung.

## 3. Persyaratan yang Dikerjakan

Persyaratan yang sudah terpenuhi sebelumnya: tiga InfoCard personal, tiga ItemCard
dengan ikon dan label, `MyHomePage` StatelessWidget, SnackBar, pemisahan `main.dart`
dan `menu.dart`, serta analisis bersih.

Persyaratan yang dikerjakan pada Checkpoint 2:

- Menambahkan warna latar eksplisit pada model `ItemHomepage`.
- Memberi tiga warna berbeda dan kontras pada tiga kartu aksi.
- Memakai warna model langsung di `ItemCard`.
- Menambah widget test untuk warna dan ikon.
- Memverifikasi ulang layout 320/390/768/1280 px dan runtime browser.

## 4. Refactor ItemHomepage

`ItemHomepage` sekarang menyimpan `Color color` sebagai data item:

```dart
class ItemHomepage {
  final String name;
  final IconData icon;
  final Color color;

  const ItemHomepage(this.name, this.icon, this.color);
}
```

Daftar item tetap `const` dan berisi:

```dart
ItemHomepage('Lihat Proyek', Icons.folder, Color(0xFF1565C0))
ItemHomepage('Tambah Proyek', Icons.add_circle, Color(0xFF2E7D32))
ItemHomepage('Logout', Icons.logout, Color(0xFFBF360C))
```

Tidak ada percabangan nama-ke-warna di `ItemCard`.

## 5. Implementasi Warna ItemCard

`Material` pada `ItemCard` memakai `color: item.color`. Struktur `Material` + `InkWell`,
border radius 12, ikon putih, label, padding, `FittedBox(scaleDown)`, dan SnackBar
tidak berubah. Tidak ada state baru, animasi, atau navigasi.

## 6. Keamanan Kontras dan Aksesibilitas

Kontras dihitung dengan rumus WCAG relatif luminance terhadap teks/ikon putih:

| Aksi | Warna | Rasio kontras |
|---|---|---|
| Lihat Proyek | `#1565C0` (blue 800) | 5.75:1 |
| Tambah Proyek | `#2E7D32` (green 800) | 5.13:1 |
| Logout | `#BF360C` (deep orange 900) | 5.60:1 |

Ketiganya memenuhi ambang WCAG AA 4.5:1 untuk teks normal. Kandidat deep orange 800
(`#D84315`) ditolak karena hanya 4.44:1. Ketiga warna juga berbeda secara visual dan
dibedakan lebih lanjut oleh ikon serta label, bukan hanya hue.

## 7. Pengujian Widget

- Seluruh 8 test Checkpoint 1 dipertahankan.
- Test menu diperluas untuk memeriksa ikon `folder`, `add_circle`, dan `logout`.
- Test baru memeriksa tiga `ItemCard`, tiga warna unik, nilai palet, dan bahwa
  `Material` hasil render memakai `item.color` dari model.
- Total: 9 test lulus.

## 8. Browser dan Responsive Testing

Runtime diuji melalui Flutter Web debug server dan Playwright/Chromium
(`flutter run -d web-server`), bukan window Chrome interaktif.

- Viewport 320x640, 390x844, 768x1024, 1280x800: identitas lengkap, tiga menu tampil,
  tidak ada error console.
- Ketiga SnackBar diuji dan sesuai nama tombol.
- Screenshot 390x844: `.playwright-mcp/page-2026-11-13T17-00-57-388Z.png`.
- Warna terlihat jelas berbeda: biru, hijau, dan oranye gelap.

## 9. Hasil Flutter Analyze dan Build

```text
dart format lib test : 3 file, 0 changed
flutter analyze      : No issues found!
flutter test         : 9 test lulus
flutter build web    : ✓ Built build/web
```

## 10. Perubahan File

Perubahan Checkpoint 2:

```text
lib/menu.dart          (ItemHomepage.color, palet item, Material color)
test/widget_test.dart  (ikon, warna unik, Material memakai item.color)
docs/tugas-7/PROGRESS_2.md (baru)
```

Tidak ada perubahan `lib/main.dart`, `pubspec.yaml`, tema, atau README.

## 11. Kesenjangan yang Tersisa

- README masih memuat identitas contoh Tutorial 08 dan belum memiliki `### Tugas 7`.
- Enam jawaban reflektif belum ditulis.
- AI disclosure dan bukti prompting belum ditulis.
- Final QA dan `docs/tugas-7/FINAL_REPORT.md` belum dibuat.
- Commit Checkpoint 2 belum dibuat; pengguna yang akan melakukan staging, commit, dan push.

## 12. Rencana Finalisasi

Checkpoint 3 akan memperbarui README (identitas, setup, `### Tugas 7` dengan enam
jawaban), menulis AI disclosure faktual, menjalankan final QA, membuat laporan akhir,
dan menyiapkan tautan commit untuk SCELE sebelum 16 November 2026 23.59 WIB.

## 13. Rekomendasi Commit Manual

```text
feat(flutter): customize portfolio actions with distinct card colors
```

File yang disarankan untuk di-stage: `lib/menu.dart`, `test/widget_test.dart`,
`docs/tugas-7/PROGRESS_2.md`.
