# Individual Assignment 7 — Final Report

## 1. Executive Summary

Individual Assignment 7 telah diselesaikan pada sisi implementasi dan dokumentasi.
Aplikasi Flutter `myportofolio_mobile` menampilkan identitas personal, tiga InfoCard,
tiga ItemCard dengan ikon/label, tiga warna berbeda yang memenuhi kontras WCAG AA,
serta SnackBar yang sesuai. Enam pertanyaan reflektif dan AI disclosure telah ditulis.

Satu langkah tersisa di luar kendali agen: pengguna harus membuat commit final,
push, dan mengirim tautan commit ke SCELE sebelum 16 November 2026 23.59 WIB.

## 2. Coursework Context

- Mata kuliah: Pemrograman Berbasis Platform (CSGE602022), Semester Gasal 2026/2027.
- Proyek: aplikasi mobile portofolio pribadi Glenn Josia Devano.
- Prasyarat: Tutorial 08 Basic Flutter.
- Backend Django `myportofolio` terpisah dan tidak diubah.
- Integrasi API DRF bukan bagian dari assignment ini.

## 3. Development Timeline

| Tahap | Tanggal | Commit | Isi |
|---|---|---|---|
| Tutorial 08 | 2026-11-11 | `9783fb4` | Aplikasi dasar Flutter, InfoCard, ItemCard, SnackBar |
| Checkpoint 1 | 2026-11-13 | `eb96955` | Identitas personal, regression test, `PROGRESS_1.md` |
| Checkpoint 2 | 2026-11-14 | `e080acd` | `ItemHomepage.color`, tiga warna, test warna, `PROGRESS_2.md` |
| Checkpoint 3 | 2026-11-14 | belum dibuat | README final, enam refleksi, AI disclosure, laporan ini |

Tanggal diambil dari `git log --date=short`. Tidak ada commit yang dibuat atau
di-backdate oleh agen.

## 4. Requirements Compliance

| Requirement | Implementasi | Bukti | Status |
|---|---|---|---|
| Lanjut proyek Tutorial 08 | Proyek yang sama, repo yang sama | `git log`, remote | PASS |
| `main.dart` / `menu.dart` terpisah | Bootstrap vs halaman | `lib/main.dart`, `lib/menu.dart` | PASS |
| `MyHomePage` StatelessWidget | `extends StatelessWidget` | source + widget test | PASS |
| Identitas NPM | `2506614712` | source, test, runtime | PASS |
| Identitas nama | `Glenn Josia Devano` | source, test, runtime | PASS |
| Identitas kelas | `PBP F` | source, test, runtime | PASS |
| Tiga InfoCard | NPM, Name, Class | widget test + screenshot | PASS |
| ≥3 ItemCard relevan | Lihat Proyek, Tambah Proyek, Logout | widget test + runtime | PASS |
| Ikon dan label | folder, add_circle, logout | widget test + runtime | PASS |
| Warna berbeda | blue 800, green 800, deep orange 900 | test warna + screenshot | PASS |
| `ItemHomepage.color` | field `Color color` | `menu.dart` | PASS |
| `ItemCard` memakai model color | `Material(color: item.color)` | source + test render | PASS |
| SnackBar sesuai tombol | 3 pesan diuji | widget test + Playwright | PASS |
| Tanpa API/login/navigasi palsu | hanya SnackBar | source | PASS |
| `flutter analyze` bersih | No issues found | eksekusi nyata | PASS |
| Git bertahap | 3 commit setelah Tutorial 08 (final menyusul) | `git log` | PARTIAL |
| Enam refleksi | `### Tugas 7` nomor 1–6 | README | PASS |
| AI disclosure | tools, peran, bukti, limitasi | README | PASS |
| Tautan commit final | belum ada sampai pengguna commit | — | BLOCKED (user action) |

## 5. Portfolio Identity

```text
Nama  : Glenn Josia Devano
NPM   : 2506614712
Kelas : PBP F
```

Diverifikasi di `lib/menu.dart`, widget test, dan render browser. Identitas contoh
Burhan tidak lagi digunakan sebagai identitas aktif.

## 6. Flutter Widget Architecture

```text
MyApp
└── MaterialApp
    └── MyHomePage
        └── Scaffold
            ├── AppBar
            │   └── Text('MyPortfolio')
            └── SingleChildScrollView
                └── Column
                    ├── Row
                    │   ├── Expanded → InfoCard
                    │   ├── Expanded → InfoCard
                    │   └── Expanded → InfoCard
                    ├── SizedBox
                    └── Center
                        └── Column
                            ├── Padding → Text sambutan
                            └── GridView.count
                                └── ItemCard ×3
                                    └── Material → InkWell → Container
                                        → Center → FittedBox → Column
                                        → Icon + Text
```

`MyHomePage`, `InfoCard`, dan `ItemCard` adalah custom widget. `ItemHomepage`
adalah model data, bukan widget.

## 7. ItemHomepage Color Implementation

```dart
class ItemHomepage {
  final String name;
  final IconData icon;
  final Color color;

  const ItemHomepage(this.name, this.icon, this.color);
}
```

Palet:

| Aksi | Warna | Kontras vs putih |
|---|---|---|
| Lihat Proyek | `#1565C0` | 5.75:1 |
| Tambah Proyek | `#2E7D32` | 5.13:1 |
| Logout | `#BF360C` | 5.60:1 |

Tidak ada percabangan warna berdasarkan nama tombol. Deep orange 800 `#D84315`
ditolak karena kontras 4.44:1.

## 8. SnackBar Interactions

Setiap `ItemCard` memakai `ScaffoldMessenger.of(context)` dengan
`hideCurrentSnackBar()` lalu `showSnackBar`:

```text
Kamu telah menekan tombol Lihat Proyek!
Kamu telah menekan tombol Tambah Proyek!
Kamu telah menekan tombol Logout!
```

Semua pesan diverifikasi melalui widget test dan runtime browser. Logout tidak
melakukan autentikasi nyata.

## 9. Code Quality

- `main.dart` hanya berisi bootstrap dan konfigurasi `MaterialApp`.
- `menu.dart` memisahkan halaman, widget reusable, dan model data.
- `const` dipakai pada konstruktor dan nilai yang memungkinkan.
- Tidak ada import tak terpakai, variabel mati, atau counter state lama.
- Tidak ada dependency baru; `pubspec.yaml` tidak berubah.
- Tidak ada logika warna berulang.
- `flutter analyze` bersih tanpa menonaktifkan lint.

## 10. Automated Test Results

```text
dart format lib test : 3 file, 0 changed
flutter analyze     : No issues found! (5.6s)
flutter test        : 9 test lulus
flutter build web   : ✓ Built build/web (19.2s)
```

Test mencakup identitas personal, data lama absen, `MyHomePage` StatelessWidget,
tiga menu + ikon, tiga warna unik, `Material` memakai warna model, tiga SnackBar,
dan viewport 320x640 tanpa exception.

## 11. Browser Verification

Runtime diuji dengan Flutter Web debug server dan Playwright/Chromium, bukan window
Chrome interaktif:

- Halaman memuat dengan judul `MyPortfolio`.
- Identitas lengkap tampil.
- Tiga tombol tampil dan dapat ditekan.
- Tiga SnackBar sesuai.
- 0 console error.
- Viewport 320x640, 390x844, 768x1024, 1280x800 diperiksa.
- Screenshot: `.playwright-mcp/page-2026-11-14T05-01-26-804Z.png`.

## 12. Accessibility and Responsiveness

- Kontras teks/ikon putih ≥5.13:1 pada ketiga kartu.
- Perbedaan warna tidak menjadi satu-satunya pembeda; ikon dan label tetap ada.
- `InkWell` memberi feedback sentuh.
- Tidak ada overflow pada empat viewport yang diuji.
- Nama panjang tampil utuh; NPM dapat terbagi beberapa baris pada lebar sempit,
  tetapi tidak terpotong.
- `FittedBox(scaleDown)` mencegah label kartu keluar dari batas.

## 13. README and Six Reflections

`README.md` memuat:

- Deskripsi proyek dan identitas final.
- Environment dan struktur proyek.
- Arsitektur widget dan penjelasan menu/warna.
- Instruksi setup, run, test, dan build.
- Riwayat tiga checkpoint.
- Heading persis `### Tugas 7` dengan enam jawaban bernomor.
- AI disclosure, bukti prompting yang tersedia, serta limitasi.

Tidak ada tautan percakapan ChatGPT yang difabrikasi; README menyatakan bahwa
tautan tersebut tidak tersedia.

## 14. AI Usage Disclosure

Diungkapkan secara eksplisit:

- ChatGPT Website untuk diskusi konsep dan perencanaan.
- OpenCode dengan DeepSeek V4.1 Flash untuk inspeksi, edit, test, verifikasi, dan dokumentasi.
- Kontribusi manusia: identitas, alur checkpoint, environment, Git manual, keputusan submisi.

Limitasi dan koreksi nyata didokumentasikan: ekstraksi PDF via `pdftotext`, overflow
layout yang diperbaiki, penolakan warna dengan kontras 4.44:1, dan perbedaan metrik
font widget test vs browser.

## 15. Git Development Discipline

```text
9783fb4 2026-11-11 Tutorial 08
eb96955 2026-11-13 Checkpoint 1
e080acd 2026-11-14 Checkpoint 2
```

- Commit dipisahkan berdasarkan progres bermakna.
- Pesan memakai Conventional Commits.
- Branch `main` melacak `origin/main`.
- Commit final Checkpoint 3 belum dibuat; pengguna yang akan melakukannya.

## 16. Security and Repository Hygiene

- `build/`, `.dart_tool/`, `.idea/`, dan file platform-generated di-ignore.
- `pubspec.lock` dipertahankan untuk aplikasi Flutter.
- Tidak ada `.env`, token, credential, atau screenshot di dalam perubahan proyek.
- File credential di parent workspace tidak dibaca dan tidak termasuk repository.
- Perubahan Checkpoint 3 hanya dokumentasi.
- Django tidak disentuh.

## 17. Limitations and Remaining Risks

- Android emulator/perangkat fisik belum dijalankan.
- iOS belum diverifikasi (simulator runtime dan CocoaPods warning).
- Verifikasi browser adalah Chromium web, bukan runtime native.
- NPM terbagi beberapa baris pada 320–390 px (kosmetik, tetap terbaca).
- Widget test memakai font Ahem sehingga pembungkusan teks berbeda dari browser.
- Tautan percakapan ChatGPT tidak tersedia; bukti prompting berupa catatan progres.
- Commit final dan submisi SCELE belum dilakukan.

## 18. Final Readiness

Implementasi, test, build, dokumentasi, enam refleksi, dan AI disclosure siap.
Satu-satunya blocker adalah aksi Git/submisi pengguna. Status: READY WITH LIMITATIONS
(native mobile belum diuji; commit final belum ada).

## 19. Manual Commit Recommendation

```bash
cd "/Users/devanmacbook/Documents/01_Kuliah/MAIN_KULIAH/Semester-3/PBP/Tugas-Individu/Tugas-Individu/myportofolio_mobile"
git status --short
git diff --check
git diff -- README.md

git add README.md docs/tugas-7/FINAL_REPORT.md
git diff --cached --check
git diff --cached --stat
git diff --cached --name-only

git commit -m "docs(flutter): finalize assignment 7 reflections and validation"
git push origin main
git rev-parse HEAD
```

## 20. SCELE Submission Checklist

- [ ] Commit final dibuat dan di-push ke `main`.
- [ ] Repository `glennjosia7/myportofolio_mobile` tetap publik.
- [ ] Tautan yang disalin adalah URL commit, bukan URL repository:
      `https://github.com/glennjosia7/myportofolio_mobile/commit/<hash>`.
- [ ] Tautan dibuka dalam mode incognito/anonim untuk memastikan dapat diakses.
- [ ] Tautan dikirim ke slot SCELE sebelum 16 November 2026 23.59 WIB.
- [ ] Bukti submisi disimpan.
