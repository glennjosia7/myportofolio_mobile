# myportofolio_mobile

Aplikasi mobile portofolio pribadi untuk Individual Assignment 7 mata kuliah
Pemrograman Berbasis Platform (CSGE602022), Fakultas Ilmu Komputer, Universitas Indonesia.
Proyek Flutter ini merupakan kelanjutan Tutorial 08 dan terpisah dari backend Django
`myportofolio`. Aplikasi belum terhubung ke API DRF; seluruh data identitas dan menu masih
berada di sisi klien.

## Identitas Portofolio

| Field | Nilai |
|---|---|
| Nama | Glenn Josia Devano |
| NPM | 2506614712 |
| Kelas | PBP F |

## Environment Terverifikasi

```text
macOS            27.0.1 (Apple Silicon, arm64)
Flutter          3.47.9 stable
Dart             3.13.7
Chrome           157.0.8103.39 (target web PASS)
Android SDK      36.0.0, Android toolchain PASS, lisensi diterima
Xcode            warning: simulator runtime tidak terbaca, CocoaPods belum terpasang
```

## Struktur Proyek

```text
myportofolio_mobile/
├── lib/
│   ├── main.dart              # bootstrap, MyApp, MaterialApp, tema
│   └── menu.dart              # MyHomePage, InfoCard, ItemHomepage, ItemCard
├── test/
│   └── widget_test.dart       # 9 widget test
├── docs/tugas-7/
│   ├── PROGRESS_1.md          # identitas dan baseline
│   ├── PROGRESS_2.md          # warna kartu dan aksesibilitas
│   └── FINAL_REPORT.md        # laporan final Checkpoint 3
├── android/ ios/ macos/ web/ linux/ windows/
├── analysis_options.yaml
├── pubspec.yaml
└── README.md
```

## Arsitektur Widget

`lib/main.dart` hanya berisi bootstrap aplikasi:

- `main()` memanggil `runApp(const MyApp())`.
- `MyApp` mengembalikan `MaterialApp` dengan `ColorScheme.fromSeed` (seed indigo,
  secondary amber 700) dan `useMaterial3: true`.
- `home` diarahkan ke `const MyHomePage()`.

`lib/menu.dart` berisi halaman dan komponen reusable:

- `MyHomePage` — `StatelessWidget`, menyimpan data identitas dan daftar menu.
- `InfoCard` — kartu reusable dengan `title` dan `content`.
- `ItemHomepage` — model data `name`, `icon`, dan `color` (bukan widget).
- `ItemCard` — kartu aksi `Material` + `InkWell`; tap menampilkan SnackBar.

Layout memakai `Scaffold`, `AppBar`, `SingleChildScrollView`, `Column`, `Row`,
`Expanded`, dan `GridView.count(crossAxisCount: 3, shrinkWrap: true)`.
`FittedBox(scaleDown)` menjaga label kartu tetap muat pada layar sempit tanpa
memotong teks.

## Menu Aksi

| Aksi | Ikon | Warna latar | Kontras teks putih |
|---|---|---|---|
| Lihat Proyek | `Icons.folder` | `#1565C0` (blue 800) | 5.75:1 |
| Tambah Proyek | `Icons.add_circle` | `#2E7D32` (green 800) | 5.13:1 |
| Logout | `Icons.logout` | `#BF360C` (deep orange 900) | 5.60:1 |

Warna disimpan di `ItemHomepage.color` dan dipakai langsung oleh `ItemCard`
(`Material(color: item.color)`), tanpa percabangan berdasarkan nama tombol.
Ketiganya memenuhi WCAG AA 4.5:1 untuk teks normal. Tap kartu menampilkan:

```text
Kamu telah menekan tombol [Nama Tombol]!
```

Tombol Logout hanya menampilkan SnackBar; tidak ada autentikasi, API call, atau
navigasi nyata pada assignment ini.

## Menjalankan Aplikasi

Prasyarat: Flutter SDK dan target perangkat sudah terpasang.

```bash
flutter pub get
flutter doctor
flutter run -d chrome
```

Target lain yang tersedia di mesin pengembangan: `flutter run -d macos`.
Android emulator `Medium_Phone_API_37.0` terdaftar, tetapi belum dijalankan pada
pengerjaan ini. iOS belum diverifikasi karena warning Xcode/CocoaPods.

## Analisis dan Testing

```bash
dart format lib test
flutter analyze
flutter test
flutter build web
```

Hasil verifikasi final Checkpoint 3:

```text
dart format      : 3 file, 0 changed
flutter analyze  : No issues found!
flutter test     : 9 test lulus
flutter build web: ✓ Built build/web
```

Widget test mencakup identitas personal, `MyHomePage` sebagai `StatelessWidget`,
tiga ItemCard beserta ikon, tiga warna unik dan pemakaian warna model pada
`Material`, tiga SnackBar, serta viewport 320x640 tanpa exception.

## Riwayat Pengembangan

| Tahap | Commit | Isi |
|---|---|---|
| Tutorial 08 | `9783fb4` | Aplikasi dasar, `main.dart`/`menu.dart`, InfoCard, ItemCard, SnackBar |
| Checkpoint 1 | `eb96955` | Identitas Glenn/NPM/PBP F, regression test, progress note |
| Checkpoint 2 | `e080acd` | `ItemHomepage.color`, tiga warna kontras, test warna |
| Checkpoint 3 | dibuat pengguna setelah finalisasi | README final, enam refleksi, AI disclosure, laporan final |

Tanggal commit tidak diubah atau dimanipulasi. Riwayat lengkap dapat dilihat dengan
`git log --oneline`.

## Fungsionalitas Terverifikasi

- AppBar `MyPortfolio` tampil.
- Tiga InfoCard menampilkan NPM `2506614712`, nama `Glenn Josia Devano`, kelas `PBP F`.
- Tiga ItemCard tampil dengan ikon dan label yang sesuai.
- Ketiga kartu memakai warna berbeda dan SnackBar yang benar.
- Layout tidak overflow pada 320x640, 390x844, 768x1024, dan 1280x800.
- Tidak ada console error pada verifikasi browser Chromium.

### Tugas 7

1. **Widget tree** adalah struktur hierarkis yang menggambarkan bagaimana widget
   disusun dari root sampai daun. Widget di Flutter bersifat immutable dan hanya
   merupakan konfigurasi; saat dijalankan, Flutter membentuk element tree dan render
   tree. Hubungan parent-child berarti parent menempatkan dan memberi constraint
   kepada child, sedangkan child menentukan ukurannya sendiri di dalam constraint
   tersebut dan melaporkan hasilnya. Komposisi terjadi karena widget parent membangun
   child melalui method `build`, bukan mewarisi tampilan parent. Pada proyek ini
   hierarkinya adalah `MyApp → MaterialApp → MyHomePage → Scaffold`, lalu `Scaffold`
   memiliki `AppBar` dan `SingleChildScrollView`; di dalam scroll view terdapat
   `Column` berisi `Row` tiga `InfoCard`, teks sambutan, dan `GridView.count` berisi
   tiga `ItemCard`. Setiap `InfoCard` membungkus `Card → Container → Column → Text`,
   sedangkan `ItemCard` membungkus `Material → InkWell → Container → Center →
   FittedBox → Column → Icon/Text`.

2. Widget yang benar-benar dipakai di proyek ini:
   - **Bootstrap/root:** `MyApp` (custom `StatelessWidget`) dan `MaterialApp`
     (konfigurasi aplikasi, tema, dan navigasi).
   - **Halaman dan layout:** `MyHomePage` (custom), `Scaffold` (kerangka halaman),
     `AppBar` (bar judul), `SingleChildScrollView` (scroll vertikal), `Padding`
     (jarak), `Column` (susunan vertikal), `Row` (susunan horizontal), `Expanded`
     (membagi lebar Row), `SizedBox` (jarak tetap), `Center` (memusatkan child), dan
     `GridView.count` (grid tiga kolom).
   - **Tampilan dan interaksi:** `Text` (teks), `Card` (kartu Material dengan elevasi),
     `Container` (padding/ukuran), `Material` (permukaan berwarna dan ink), `InkWell`
     (ripple dan tap), `Icon` (ikon Material), `FittedBox` (mengecilkan konten agar
     muat), dan `SnackBar` (notifikasi bawah).
   - **Widget reusable:** `InfoCard` dan `ItemCard`.
   - **Bukan widget:** `ItemHomepage` adalah model data; `ThemeData`/`ColorScheme`
     adalah konfigurasi tema; `ScaffoldMessenger` adalah API untuk menampilkan
     SnackBar; `EdgeInsets`, `BorderRadius`, dan `Color` adalah objek pendukung.
     `StatelessWidget` adalah base class, bukan widget yang diinstansiasi langsung.

3. `MaterialApp` adalah widget yang menyediakan infrastruktur aplikasi berbasis
   Material Design: tema (`ThemeData`), arah teks dan lokalisasi, `Navigator`,
   `Overlay`, media query, serta konfigurasi halaman awal. Karena layanan tersebut
   perlu tersedia bagi seluruh subtree, `MaterialApp` biasanya diletakkan dekat root,
   bukan karena secara teknis harus selalu menjadi widget paling luar. Pada proyek ini
   `runApp` menerima `MyApp`; `MyApp.build` mengembalikan `MaterialApp` dengan tema
   indigo/amber dan `home: MyHomePage()`. Dengan demikian `MyHomePage` dapat memakai
   `Theme.of(context)` dan `ScaffoldMessenger.of(context)`.

4. `StatelessWidget` adalah widget dengan konfigurasi immutable dan tidak memiliki
   objek `State` internal. Widget ini tetap dapat direbuild ketika parent-nya berubah
   atau ketika inherited widget yang dipakai berubah. `StatefulWidget` memiliki objek
   `State` mutable yang bertahan antar-rebuild; perubahan state biasanya diikuti
   `setState` agar `build` dijalankan ulang. `State` juga memiliki lifecycle seperti
   `initState`, `didUpdateWidget`, dan `dispose`. Pilih `StatelessWidget` untuk
   tampilan yang hanya bergantung pada input dan konteks, seperti `MyHomePage` yang
   datanya tetap. Pilih `StatefulWidget` bila ada data yang berubah selama halaman
   hidup, misalnya input form, timer, atau daftar yang dapat diedit. SnackBar tidak
   memaksa halaman menjadi stateful karena SnackBar dikelola oleh `ScaffoldMessenger`
   di atas halaman, bukan disimpan sebagai state `MyHomePage`.

5. `BuildContext` adalah handle ke posisi sebuah widget di element tree. Melalui
   context, widget dapat mencari ancestor yang menyediakan layanan atau data, misalnya
   `Theme.of(context)` untuk tema dan `ScaffoldMessenger.of(context)` untuk menampilkan
   SnackBar. Context bukan tempat menyimpan state dan bukan referensi global ke seluruh
   aplikasi; ia menghubungkan widget dengan lokasinya pada saat build. Di proyek ini,
   `ItemCard.build` memakai `Theme`/`ScaffoldMessenger` melalui context saat kartu
   ditekan, dan `MyHomePage.build` memakai `Theme.of(context)` untuk warna AppBar.
   Context hanya boleh dipakai selama widget masih terpasang; setelah operasi async,
   perlu pengecekan `mounted` sebelum memakai context.

6. Hot reload memasukkan perubahan kode Dart ke aplikasi yang sedang berjalan,
   membangun ulang widget tree, dan umumnya mempertahankan state yang ada. Hot restart
   mematikan dan menjalankan ulang isolate Dart: `main()` dieksekusi lagi sehingga
   state aplikasi kembali ke awal. Full restart/rebuild diperlukan untuk perubahan yang
   tidak dapat diterapkan oleh hot reload, misalnya perubahan kode native/platform,
   konfigurasi Android (`AndroidManifest.xml`, Gradle), `Info.plist`, penambahan plugin
   atau dependency native, serta perubahan mendasar pada entry point atau inisialisasi
   yang hanya dijalankan sekali. Perubahan biasa pada `build` seperti teks, warna, atau
   layout cukup dengan hot reload. Pada proyek ini, mengubah warna `ItemHomepage.color`
   atau teks SnackBar dapat diuji dengan hot reload, sedangkan perubahan konfigurasi
   platform memerlukan restart/rebuild penuh.

## AI Usage Disclosure

### Tools yang Digunakan

- **ChatGPT Website** — diskusi konsep Flutter/Dart, pemahaman requirement, dan
  penyusunan rencana tiga checkpoint serta prompt kerja.
- **OpenCode dengan model DeepSeek V4.1 Flash** — inspeksi repository, perubahan kode,
  pembuatan test, `flutter analyze`, `flutter test`, `flutter build web`, verifikasi
  browser melalui Playwright, dan penyusunan dokumentasi progres.
- **Human developer (Glenn Josia Devano)** — menetapkan identitas portofolio, memilih
  alur tiga checkpoint, menyiapkan environment pengembangan, serta menjalankan staging,
  commit, dan push secara manual.

### Strategi Prompting dan Validasi

1. Membaca PDF tugas dan memeriksa repository sebelum mengubah kode.
2. Menetapkan baseline yang dapat diverifikasi (analyze bersih, test lulus).
3. Memecah pekerjaan menjadi tiga checkpoint dengan batas yang jelas.
4. Menerapkan perubahan kecil per checkpoint dan tidak mengerjakan checkpoint berikutnya.
5. Menjalankan formatter, analyzer, widget test, dan Web build setelah perubahan.
6. Memverifikasi perilaku nyata di browser, bukan hanya menganalisis kode.
7. Mencatat risiko dan pekerjaan yang belum selesai di `docs/tugas-7/`.
8. Menyerahkan seluruh Git operation kepada pengguna.

### Bukti Prompting

Tautan percakapan ChatGPT tidak disertakan karena tidak tersedia pada repository.
Bukti yang tersedia adalah catatan progres dan riwayat commit:

- `docs/tugas-7/PROGRESS_1.md` dan `docs/tugas-7/PROGRESS_2.md`.
- Riwayat commit `9783fb4`, `eb96955`, `e080acd` (dan commit final setelah finalisasi).
- Arahan kerja yang digunakan menekankan batas scope, misalnya:
  > "DO NOT implement distinct menu colors in this first session."
  > "DO NOT execute git add, git commit, git push."

### Keterbatasan AI dan Koreksi

- AI tidak dapat membaca PDF sebagai input langsung pada sesi ini; teks PDF diekstrak
  dengan `pdftotext` dan tetap diverifikasi terhadap checklist manual.
- Layout sempat overflow pada viewport sempit. Overflow 0.286 px pada Row InfoCard dan
  16–37 px pada ItemCard ditemukan lewat test/browser, lalu diperbaiki dengan `Expanded`
  dan `FittedBox(scaleDown)`.
- Kandidat warna deep orange 800 (`#D84315`) ditolak karena kontras putih hanya 4.44:1;
  diganti deep orange 900 (`#BF360C`) dengan 5.60:1.
- Widget test memakai font Ahem yang metriknya berbeda dari browser; hasil test tidak
  otomatis membuktikan tampilan perangkat nyata. Karena itu runtime browser juga diuji.
- Verifikasi browser memakai Chromium web, bukan Android/iOS. Klaim runtime mobile
  native tidak dibuat.
- Hasil yang dilaporkan agen didasarkan pada perintah yang benar-benar dijalankan;
  tidak ada percakapan, tautan, atau hasil test yang difabrikasi.

## Keterbatasan

- Belum ada integrasi API DRF, autentikasi, atau navigasi. Tombol menu hanya menampilkan
  SnackBar sesuai requirement assignment.
- Android emulator dan perangkat fisik belum dijalankan; iOS belum diverifikasi karena
  warning Xcode/CocoaPods.
- Verifikasi visual dilakukan pada Chromium web (Playwright), bukan window Chrome
  interaktif atau perangkat native.
- NPM dapat terbungkus beberapa baris pada layar 320–390 px, tetapi tetap terbaca
  lengkap dan tidak overflow.
- README ini adalah dokumentasi final Assignment 7; tautan commit final baru tersedia
  setelah pengguna melakukan commit dan push manual.

## Repository

```text
https://github.com/glennjosia7/myportofolio_mobile
git@github.com:glennjosia7/myportofolio_mobile.git
```

Repositori harus tetap publik. Submisi SCELE menggunakan tautan commit final, bukan
tautan halaman repository. Deadline: 16 November 2026, 23.59 WIB.
