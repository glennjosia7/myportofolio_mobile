# myportofolio_mobile

Aplikasi mobile portofolio PBP (CSGE602022) — hasil Tutorial 08: Basic Flutter.
Proyek ini terpisah dari backend Django `myportofolio` dan belum terhubung ke API DRF.

## Ringkasan Tutorial 08

- Membuat proyek Flutter baru bernama `myportofolio_mobile`.
- Memisahkan halaman menu (`lib/menu.dart`) dari bootstrap aplikasi (`lib/main.dart`).
- Mengubah `MyHomePage` dari StatefulWidget menjadi StatelessWidget.
- Membuat widget reusable `InfoCard` dan `ItemCard`.
- Menampilkan tiga kartu identitas dan tiga kartu aksi dalam `GridView.count`.
- Menampilkan `SnackBar` saat kartu aksi ditekan.

## Environment Terverifikasi

```text
macOS            27.0.1 (Apple Silicon, arm64)
Flutter          3.47.9 stable
Dart             3.13.7
Android SDK      36.0.0
Android toolchain PASS, semua lisensi diterima
Chrome           157.0.8103.39 (target web PASS)
Xcode            warning: simulator runtime tidak terbaca, CocoaPods belum terpasang
```

## Struktur Proyek

```text
myportofolio_mobile/
├── lib/
│   ├── main.dart        # entry point, MyApp, MaterialApp, tema
│   └── menu.dart        # MyHomePage, InfoCard, ItemHomepage, ItemCard
├── test/
│   └── widget_test.dart # widget test halaman portofolio
├── android/ ios/ macos/ web/ ...
├── analysis_options.yaml
├── pubspec.yaml
└── README.md
```

## Penjelasan Kode

`lib/main.dart` menjalankan `MyApp`, membuat `MaterialApp` dengan `ColorScheme.fromSeed`
(seed indigo, secondary amber 700) dan `useMaterial3: true`, lalu menampilkan
`MyHomePage`.

`lib/menu.dart` berisi:

- `MyHomePage` — StatelessWidget dengan data contoh NPM `2406000001`, nama `Burhan`,
  kelas `PBP A`, serta daftar tiga menu.
- `InfoCard` — kartu reusable berisi `title` dan `content`.
- `ItemHomepage` — model data sederhana (`name`, `icon`).
- `ItemCard` — kartu aksi berbasis `Material` + `InkWell`; tap memunculkan SnackBar
  `Kamu telah menekan tombol <nama>!`.

Layout memakai `Scaffold`, `AppBar`, `SingleChildScrollView`, `Column`, `Row`,
dan `GridView.count(crossAxisCount: 3, shrinkWrap: true)`. `SingleChildScrollView`
dan `NeverScrollableScrollPhysics` mencegah overflow dan nested scroll pada layar kecil.

## Menjalankan Aplikasi

```bash
cd myportofolio_mobile
flutter pub get
flutter run -d chrome
```

Target lain yang tersedia di mesin ini: `flutter run -d macos`.
Android emulator `Medium_Phone_API_37.0` terdaftar, tetapi tidak dijalankan pada Tutorial 08.

## Analisis dan Testing

```bash
dart format lib test
flutter analyze
flutter test
```

Hasil verifikasi terakhir:

```text
dart format     : 3 file diproses, format diterapkan
flutter analyze : No issues found!
flutter test    : 6 test lulus
```

## Fungsionalitas Terverifikasi

- AppBar `MyPortfolio` tampil.
- Tiga InfoCard tampil: NPM `2406000001`, Name `Burhan`, Class `PBP A`.
- Tiga ItemCard tampil: `Lihat Proyek`, `Tambah Proyek`, `Logout`.
- Tap setiap kartu menampilkan SnackBar yang sesuai (diverifikasi widget test dan Chrome).
- Tidak ada error console dan tidak ada overflow pada viewport 1280x800, 390x844, dan 320x640.

## Keterbatasan

- Data masih data contoh Tutorial 08 (Burhan), belum identitas pemilik portofolio.
- Belum ada koneksi ke API DRF `/api/v1/`; belum ada HTTP client, autentikasi, atau routing.
- Tombol hanya menampilkan SnackBar, belum menjalankan aksi nyata.
- Xcode/iOS belum diverifikasi: simulator runtime tidak terbaca dan CocoaPods belum terpasang.
- Kontras teks putih di atas amber 700 rendah; mengikuti desain tutorial dan akan
  disesuaikan pada Individual Assignment 7.
- Android emulator belum dijalankan pada sesi ini.

## Persiapan Individual Assignment 7

- Ganti data Burhan pada `InfoCard` dengan identitas pemilik portofolio.
- Sesuaikan menu `ItemCard` dengan bagian portofolio dari Tugas 3–6.
- Beri warna latar berbeda untuk setiap kartu aksi.
- Integrasi API DRF direncanakan pada tutorial berikutnya, bukan pada Tutorial 08.
