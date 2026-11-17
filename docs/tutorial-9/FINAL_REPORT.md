# Tutorial 09 — Final Report

## 1. Executive Summary

Tutorial 09 (Flutter Navigation, Layouts, Forms, and Input Elements) selesai
diimplementasikan dan diverifikasi. Aplikasi memiliki drawer navigation, halaman
`ProjectFormPage`, lima input form, validasi, dropdown kategori, dialog konfirmasi,
reset state, dan navigasi dari kartu Tambah Proyek. Identitas serta fitur Tugas 7
tetap dipertahankan. Analyzer bersih, 20 widget test lulus, Web build berhasil, dan
runtime Chromium diuji pada empat viewport tanpa console error.

Commit dan push belum dilakukan; keduanya menjadi aksi manual pengguna.

## 2. Repository Audit

```text
Root       : .../Tugas-Individu/myportofolio_mobile
Branch     : main (sinkron origin/main)
Remote     : git@github.com:glennjosia7/myportofolio_mobile.git
Author     : DevCoder-7 <177463070+DevCoder-7@users.noreply.github.com>
Baseline   : 8d6512c docs(flutter): finalize assignment 7 reflections and validation
```

Riwayat:

```text
8d6512c Tugas 7 Checkpoint 3
e080acd Tugas 7 Checkpoint 2
eb96955 Tugas 7 Checkpoint 1
9783fb4 Tutorial 08
```

Working tree bersih sebelum pekerjaan dimulai. Baseline diverifikasi ulang:
`flutter analyze` bersih, 9 test lulus, Web build berhasil.

## 3. PDF Audit

Sumber: `/Users/devanmacbook/Documents/01_Kuliah/MAIN_KULIAH/Semester-3/PBP/Tutorial/tutorial-9.pdf`,
27 halaman. Teks diekstrak penuh dengan `pdftotext -layout` karena model tidak
mendukung input PDF langsung.

Materi yang dibaca dan dipetakan: Navigator push/pop/pushReplacement, layout
Column/Row/Stack/ListView/GridView/Expanded/Padding/SizedBox/SingleChildScrollView,
Form/TextFormField/validator/onChanged, DropdownButtonFormField `initialValue`,
ElevatedButton/showDialog/AlertDialog/TextButton, struktur `screens/` dan `widgets/`,
serta ketentuan pengumpulan tautan commit.

## 4. Requirement Compliance Matrix

| Requirement | Implementasi | Bukti | Status |
|---|---|---|---|
| Lanjut proyek dan repo Tutorial 08 | Proyek/repo sama | `git log`, remote | PASS |
| Material UI sesuai Flutter 3.47 | `material_ui ^1.11.1` | `pubspec.yaml`, import | PASS |
| Drawer dengan header | `LeftDrawer`, `DrawerHeader` indigo | `lib/widgets/left_drawer.dart` | PASS |
| Menu Home | `pushReplacement` ke `MyHomePage` | source + test | PASS |
| Menu Add Project | `pushReplacement` ke `ProjectFormPage` | source + test | PASS |
| Drawer pada home dan form | `drawer: const LeftDrawer()` | source | PASS |
| `ProjectFormPage` StatefulWidget | `State` + `GlobalKey<FormState>` | source | PASS |
| `MyHomePage` tetap Stateless | `extends StatelessWidget` | source + test | PASS |
| Lima field input | Nama, Deskripsi, Kategori, Teknologi, Tautan | test + runtime | PASS |
| Validasi nama | trim + pesan error | test kosong/whitespace | PASS |
| Validasi deskripsi | trim + pesan error | test kosong/whitespace | PASS |
| Dropdown lima kategori | 5 item, default Web Development | test + runtime | PASS |
| `initialValue` bukan `value` | `initialValue: _category` | source | PASS |
| Save memvalidasi dulu | `_formKey.currentState!.validate()` | source + test | PASS |
| Dialog lima nilai | Nama, Deskripsi, Kategori, Teknologi, Tautan | test + runtime | PASS |
| OK menutup dan reset | pop, reset FormState + state internal | test + runtime | PASS |
| Tanpa stale data | submit kedua memakai nilai baru | test | PASS |
| ItemCard Tambah Proyek push | `Navigator.push` setelah SnackBar | test + runtime | PASS |
| SnackBar tetap tampil | tiga pesan lama | test + runtime | PASS |
| Back dari form | sistem/browser back | test + runtime | PASS |
| Struktur screens/widgets | 5 file final, tanpa file lama | `find lib` | PASS |
| Tanpa TODO/Placeholder | pencarian `rg` | bersih | PASS |
| `flutter analyze` | No issues found | eksekusi | PASS |
| Widget test | 20 lulus | eksekusi | PASS |
| Web build | berhasil | eksekusi | PASS |
| Responsif 320/390/768/1280 | tanpa overflow/error | test + browser | PASS |
| Data tidak disimpan | hanya dialog | source | PASS |
| Git manual | belum commit/push | `git status` | USER ACTION |

## 5. Code Changes

```text
lib/main.dart
lib/screens/menu.dart
lib/screens/project_form.dart
lib/widgets/left_drawer.dart
lib/widgets/project_card.dart
test/widget_test.dart
pubspec.yaml
pubspec.lock
README.md
docs/tutorial-9/FINAL_REPORT.md
```

Perubahan utama:

- Migrasi seluruh import Material ke `package:material_ui/material_ui.dart`.
- `LeftDrawer` dengan header, Home, dan Add Project.
- `ProjectFormPage` dengan lima input dan validasi.
- Navigasi `push` pada kartu Tambah Proyek dan `pushReplacement` pada drawer.
- Dialog konfirmasi dan reset form.
- `ItemHomepage` + `ItemCard` dipindahkan ke `widgets/project_card.dart`.
- `MyHomePage` dan `InfoCard` dipindahkan ke `screens/menu.dart`.
- Test diperluas dari 9 menjadi 20.

## 6. Refactoring

Struktur final:

```text
lib/
├── main.dart
├── screens/
│   ├── menu.dart
│   └── project_form.dart
└── widgets/
    ├── left_drawer.dart
    └── project_card.dart
```

- `lib/menu.dart` dan `lib/project_form.dart` sudah tidak ada.
- `ItemCard` hanya didefinisikan sekali di `widgets/project_card.dart`.
- Import diperbarui di main, screens, widgets, dan test.
- Tidak ada import lama `package:myportofolio_mobile/menu.dart` atau
  `package:myportofolio_mobile/project_form.dart`.
- Tidak ada TODO, Placeholder, atau file duplikat.
- Pemindahan dilakukan secara terkontrol dengan `mv` dan edit import, bukan fitur
  refactor IDE. Semua referensi diverifikasi lewat `flutter analyze`.

## 7. Dependency Changes

```text
+ material_ui: ^1.11.1
```

Paket `material_ui` 1.11.1 membutuhkan Dart `^3.13.0` dan Flutter `>=3.47.0`;
environment aktual Flutter 3.47.9 dan Dart 3.13.7 memenuhi syarat. `pubspec.lock`
diperbarui oleh `flutter pub add material_ui`. Tidak ada dependency lain yang
ditambahkan secara manual.

## 8. Testing Results

```text
dart format lib test : 6 file, 0 changed
flutter analyze      : No issues found!
flutter test         : 20 test lulus
flutter build web    : ✓ Built build/web
```

Cakupan test: identitas, StatelessWidget, tiga kartu/ikon, tiga warna unik, SnackBar,
drawer, navigasi drawer, navigasi kartu, back, lima field, default kategori,
perubahan kategori, validasi kosong/whitespace, dialog lima nilai, OK/reset,
anti-stale, serta overflow 320x640.

Tidak ada test yang dihapus atau dilemahkan. Test lama Tugas 7 dipertahankan dan
disesuaikan import-nya setelah refactor.

## 9. Browser Verification

Flutter Web dijalankan melalui `flutter run -d web-server` dan diuji dengan
Playwright/Chromium (bukan window Chrome interaktif):

- Home: identity Glenn/NPM/PBP F, tiga kartu/warna, AppBar.
- Drawer: header, Home, Add Project; navigasi berhasil.
- Form: lima field, dropdown lima kategori, validasi kosong.
- Dialog: lima nilai benar, termasuk kategori yang diubah ke Mobile Development.
- OK: dialog tertutup, field kosong, kategori kembali Web Development.
- Kartu Tambah Proyek: SnackBar tampil dan form terbuka.
- Browser Back: kembali ke halaman utama.
- Viewport 320x640, 390x844, 768x1024, 1280x800: tampil, tanpa error.
- Console error: 0. Ada warning semantics framework terkait label route, bukan
  kegagalan aplikasi.

Screenshot: `.playwright-mcp/page-2026-11-17T13-11-38-343Z.png`.

## 10. Responsiveness

- 320x640: home dan form tanpa RenderFlex overflow.
- 390x844, 768x1024, 1280x800: layout stabil.
- Header drawer memakai `FittedBox(scaleDown)` agar teks tidak overflow pada
  lebar sempit.
- Dropdown memakai `isExpanded: true` agar selected item tidak overflow.
- Nama panjang tetap terbaca; NPM boleh terbagi beberapa baris.
- SnackBar dan dialog tetap dapat digunakan.

## 11. Regression Verification

- Identitas Glenn Josia Devano / 2506614712 / PBP F tetap.
- Tiga InfoCard tetap.
- Tiga ItemCard dan ikonnya tetap.
- Warna blue/green/deep orange dan pemakaian `ItemHomepage.color` tetap.
- SnackBar ketiga tombol tetap.
- `MyHomePage` tetap StatelessWidget.
- Test lama tidak dihapus.
- Django tidak disentuh.

## 12. Git Diff

Perubahan yang diharapkan:

```text
M  lib/main.dart
D  lib/menu.dart
M  pubspec.yaml
M  pubspec.lock
M  test/widget_test.dart
?? lib/screens/menu.dart
?? lib/screens/project_form.dart
?? lib/widgets/left_drawer.dart
?? lib/widgets/project_card.dart
M  README.md
?? docs/tutorial-9/FINAL_REPORT.md
```

`git diff --check` bersih. Tidak ada staging/commit/push oleh agen.

## 13. Security Audit

- `build/`, `.dart_tool/`, `.idea/`, dan artefak generated tetap di-ignore.
- Tidak ada `.env`, token, credential, atau file sensitif di proyek.
- Tidak ada API key atau koneksi jaringan baru.
- Tidak ada screenshot yang dimasukkan ke repository.
- Credential di parent workspace tidak dibaca dan tidak termasuk commit.
- Form tidak mengirim data ke server.

## 14. Limitations

- Data form tidak disimpan; hanya ditampilkan di dialog (sesuai tutorial).
- Tidak ada API DRF, autentikasi, atau logout nyata.
- Android/iOS belum dijalankan; verifikasi hanya Web/Chromium.
- Warning semantics route muncul di console browser; bukan error aplikasi.
- Widget test memakai font Ahem sehingga pembungkusan teks dapat berbeda dari
  browser; runtime browser tetap diuji.
- Commit final dan submisi SCELE belum dilakukan.

## 15. Manual Commit Instructions

Review lebih dahulu:

```bash
cd "/Users/devanmacbook/Documents/01_Kuliah/MAIN_KULIAH/Semester-3/PBP/Tugas-Individu/Tugas-Individu/myportofolio_mobile"
git status --short
git diff --check
git diff --stat
```

Stage seluruh file Tutorial 09 yang relevan:

```bash
git add lib/main.dart lib/screens lib/widgets test/widget_test.dart pubspec.yaml pubspec.lock README.md docs/tutorial-9/FINAL_REPORT.md
git add -u lib/menu.dart
git diff --cached --check
git diff --cached --stat
git diff --cached --name-only
git commit -m "feat(flutter): complete tutorial 09 navigation and project form"
git push origin main
git rev-parse HEAD
```

Tautan SCELE:

```text
https://github.com/glennjosia7/myportofolio_mobile/commit/<hash>
```

## 16. Final Verdict

```text
TUTORIAL 09
- Implementation: COMPLETE
- Flutter analyze: PASS
- Flutter tests: PASS (20)
- Web build: PASS
- Browser runtime: PASS (Chromium, 0 console error)
- Tutorial 08 regression: PASS
- Tugas 7 regression: PASS
- Git commit: USER ACTION REQUIRED
- Git push: USER ACTION REQUIRED
- SCELE: USER ACTION REQUIRED

Readiness: READY WITH LIMITATIONS
```

Deadline Tutorial 09: 18 November 2026, 23.59 WIB.
