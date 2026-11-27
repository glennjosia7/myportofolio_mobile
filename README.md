# myportofolio_mobile

[![CI](https://github.com/glennjosia7/myportofolio_mobile/actions/workflows/main.yaml/badge.svg?branch=main)](https://github.com/glennjosia7/myportofolio_mobile/actions/workflows/main.yaml)

Aplikasi mobile portofolio pribadi untuk Tutorial 08–09 dan Tugas Individu 7–8
mata kuliah Pemrograman Berbasis Platform (CSGE602022), Fakultas Ilmu
Komputer, Universitas Indonesia. Proyek Flutter ini terpisah dari backend Django
`myportofolio`. Identitas dan menu berada di sisi klien. Tutorial 09 menambahkan
drawer navigation, halaman form
proyek, validasi input, dropdown kategori, dan dialog konfirmasi. Tugas 8
menambahkan formulir Sertifikasi, pemilih tanggal, dan dialog ringkasan isian.
Tutorial 10 menghubungkan fitur Projects dengan API DRF Django.

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
Chrome           157.0.8103.79 (target web PASS)
Android SDK      36.0.0, Android toolchain PASS, lisensi diterima
Xcode            warning: simulator runtime tidak terbaca, CocoaPods belum terpasang
```

## Struktur Proyek

```text
myportofolio_mobile/
├── lib/
│   ├── main.dart              # bootstrap, MyApp, MaterialApp, tema
│   ├── screens/
│   │   ├── menu.dart          # MyHomePage dan InfoCard
│   │   ├── project_form.dart  # ProjectFormPage dan state form
│   │   └── certification_form.dart # form, validasi, dan ringkasan sertifikasi
│   └── widgets/
│       ├── left_drawer.dart   # navigasi drawer
│       └── project_card.dart  # ItemHomepage dan ItemCard
├── test/
│   ├── widget_test.dart       # 24 test navigasi dan regresi
│   └── certification_form_test.dart # 9 test validasi, dialog, dan viewport
├── docs/tugas-7/
│   ├── PROGRESS_1.md          # identitas dan baseline
│   ├── PROGRESS_2.md          # warna kartu dan aksesibilitas
│   └── FINAL_REPORT.md        # laporan final Checkpoint 3
├── docs/tutorial-9/
│   └── FINAL_REPORT.md        # laporan Tutorial 09
├── docs/tugas-8/
│   ├── PROGRESS_1.md         # fondasi dan navigasi
│   ├── PROGRESS_2.md         # validasi, dialog, dan QA
│   └── FINAL_REPORT.md       # audit dan verifikasi akhir
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

`lib/screens/menu.dart` berisi halaman utama dan komponen tampilan:

- `MyHomePage` — `StatelessWidget`, menyimpan data identitas dan daftar menu.
- `InfoCard` — kartu reusable dengan `title` dan `content`.

`lib/widgets/` berisi komponen yang dipakai lintas halaman:

- `project_card.dart` — `ItemHomepage` menyimpan `name`, `icon`, `color`, dan
  tujuan opsional. `ItemCard` menampilkan SnackBar dan membuka halaman tujuan.
- `left_drawer.dart` — `LeftDrawer` dengan menu Home, Add Project, dan Add Certification.

`lib/screens/project_form.dart` berisi `ProjectFormPage` (`StatefulWidget`) dengan
`Form`, lima input, validasi, dropdown kategori, dan `AlertDialog` konfirmasi.

`lib/screens/certification_form.dart` berisi `CertificationFormPage` dengan empat
input teks, dua pemilih tanggal, validasi per isian, dan dialog ringkasan.

Layout memakai `Scaffold`, `AppBar`, `SingleChildScrollView`, `Column`, `Row`,
`Expanded`, `GridView.count(crossAxisCount: 3, shrinkWrap: true)`, `Form`,
`TextFormField`, `DropdownButtonFormField`, `Drawer`, dan `ListView`.
`FittedBox(scaleDown)` menjaga label kartu tetap muat pada layar sempit tanpa
memotong teks.

## Menu Aksi

| Aksi | Ikon | Warna latar | Kontras teks putih |
|---|---|---|---|
| Lihat Proyek | `Icons.folder` | `#1565C0` (blue 800) | 5.75:1 |
| Tambah Proyek | `Icons.add_circle` | `#2E7D32` (green 800) | 5.13:1 |
| Logout | `Icons.logout` | `#BF360C` (deep orange 900) | 5.60:1 |
| Tambah Sertifikasi | `Icons.workspace_premium` | `#6A1B9A` (purple 800) | 9.39:1 |

Warna disimpan di `ItemHomepage.color` dan dipakai langsung oleh `ItemCard`
(`Material(color: item.color)`), tanpa percabangan berdasarkan nama tombol.
Keempatnya memenuhi WCAG AA 4.5:1 untuk teks normal. Tap kartu menampilkan:

```text
Kamu telah menekan tombol [Nama Tombol]!
```

Tombol **Tambah Proyek** menampilkan SnackBar lalu membuka `ProjectFormPage` dengan
`Navigator.push()`, sehingga tombol Back browser/kembali sistem dapat dipakai.
Tombol Lihat Proyek dan Logout hanya menampilkan SnackBar; tidak ada autentikasi,
API call, atau logout nyata pada assignment ini.

## Tutorial 09 — Navigation, Layouts, Forms, and Input Elements

Tutorial 09 menambahkan alur navigasi dan form proyek:

- `LeftDrawer` tersedia pada halaman utama dan halaman form.
- Pada Tutorial 09, **Home** dan **Add Project** memakai `Navigator.pushReplacement()`.
  Tugas 8 memperbarui navigasi drawer agar Home tetap menjadi rute dasar.
- Kartu **Tambah Proyek** memakai `Navigator.push()` dan tetap menampilkan SnackBar.
- Form memiliki lima input: Nama Proyek, Deskripsi, Kategori, Teknologi, Tautan.
- Nama dan Deskripsi wajib diisi; input whitespace-only ditolak.
- Kategori memakai `DropdownButtonFormField` dengan lima pilihan dan default
  `Web Development`.
- Tombol Save memvalidasi seluruh form sebelum menampilkan `AlertDialog`.
- Dialog menampilkan lima nilai input dan tombol OK menutup dialog, mereset form,
  mengembalikan kategori ke default, serta membersihkan state internal.
- Data **tidak** disimpan ke database/API; dialog hanya menampilkan data sementara.

Migrasi Material mengikuti Tutorial 09: proyek memakai `material_ui: ^1.11.1`
(Flutter ≥3.47) dan import `package:material_ui/material_ui.dart` pada
`main.dart`, screens, widgets, dan test.

## Menjalankan Aplikasi

Prasyarat: Flutter 3.47.9 dengan Dart 3.13.7 dan target perangkat yang sudah terpasang.

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

Hasil verifikasi Tutorial 09:

```text
dart format      : 6 file, 0 changed
flutter analyze  : No issues found!
flutter test     : 20 test lulus
flutter build web: ✓ Built build/web
```

Widget test mencakup identitas personal, `MyHomePage` sebagai `StatelessWidget`,
tiga ItemCard beserta ikon, tiga warna unik dan pemakaian warna model pada
`Material`, tiga SnackBar, drawer, navigasi drawer dan tombol, lima input form,
validasi nama/deskripsi, dropdown kategori, dialog lima nilai, reset tanpa stale
state, serta viewport 320x640 tanpa exception.

## Riwayat Pengembangan

| Tahap | Commit | Isi |
|---|---|---|
| Tutorial 08 | `9783fb4` | Aplikasi dasar, `main.dart`/`menu.dart`, InfoCard, ItemCard, SnackBar |
| Checkpoint 1 | `eb96955` | Identitas Glenn/NPM/PBP F, regression test, progress note |
| Checkpoint 2 | `e080acd` | `ItemHomepage.color`, tiga warna kontras, test warna |
| Checkpoint 3 | `8d6512c` | README final, enam refleksi, AI disclosure, laporan final |
| Tutorial 09 | `53ba8df` | Drawer, form proyek, navigasi, Material UI, refactor screens/widgets |

Progres Tugas 8 tercatat di [tahap fondasi](docs/tugas-8/PROGRESS_1.md),
[tahap validasi](docs/tugas-8/PROGRESS_2.md), dan [laporan akhir](docs/tugas-8/FINAL_REPORT.md).

Tanggal commit tidak diubah atau dimanipulasi. Riwayat lengkap dapat dilihat dengan
`git log --oneline`.

## Fungsionalitas Terverifikasi pada Tutorial 09

- AppBar `MyPortfolio` tampil.
- Tiga InfoCard menampilkan NPM `2506614712`, nama `Glenn Josia Devano`, kelas `PBP F`.
- Tiga ItemCard tampil dengan ikon dan label yang sesuai.
- Ketiga kartu memakai warna berbeda dan SnackBar yang benar.
- Drawer dapat dibuka; menu Home dan Add Project bernavigasi dengan benar.
- Kartu Tambah Proyek membuka form dan dapat kembali dengan Back.
- Form menampilkan lima input, memvalidasi input kosong, dan menampilkan dialog
  berisi lima nilai setelah input valid.
- Tombol OK menutup dialog dan mereset form tanpa state lama.
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

### Tugas 8

1. `Navigator.push()` menambah rute dan mempertahankan halaman sebelumnya.
   `Navigator.pushReplacement()` mengganti rute paling atas. `Navigator.pop()`
   menutup rute atau elemen aktif seperti drawer. Kartu **Tambah Sertifikasi**
   memanggil `Navigator.push()` agar Back kembali ke Home. Opsi **Home** di
   drawer menutup panel dengan `pop()`, lalu menjalankan
   `popUntil((route) => route.isFirst)`. Saat berpindah antarform melalui drawer,
   `pushReplacement()` mengganti form aktif sambil mempertahankan Home.
2. `Scaffold` menyediakan struktur halaman yang konsisten melalui slot `appBar`,
   `drawer`, dan `body`. Home dan kedua halaman form memakai `LeftDrawer` yang sama,
   sehingga daftar tujuan konsisten. Home dan Form Sertifikasi mengambil warna
   latar `AppBar` dari `Theme.of(context).colorScheme.primary`, yang dibentuk dari
   seed indigo di `MyApp`.
3. Saya menyusun input Form Sertifikasi dalam satu `Column` agar mudah diikuti.
   `EdgeInsets.all(16)` memberi jarak di tepi dan `Column.spacing` memisahkan
   kontrol. `SafeArea` menjaga isi dari area sistem. `ConstrainedBox` membatasi
   lebar form menjadi 560 piksel logis di layar lebar. Saat layar sempit atau ruang
   berkurang karena papan ketik, `SingleChildScrollView` memungkinkan pengguna
   menggulir ke isian terakhir dan tombol **Simpan**.
4. `GlobalKey<FormState>` memberi tombol **Simpan** akses ke state form.
   `validate()` menjalankan `validator` setiap isian dan menampilkan pesan pada
   kolom yang bermasalah. Contohnya, `https:///verify` ditolak karena tidak memiliki
   host. `TextInputType.url` hanya menyesuaikan papan ketik. Format URL tetap
   diperiksa sebelum `FormState.save()` mengambil nilai dan membuka `AlertDialog`.
   Ringkasan bersifat lokal dan data form tidak disimpan permanen.

#### Penggunaan AI Tugas 8

Saya menggunakan ChatGPT untuk menyusun prompt kerja tiga checkpoint dan Codex
untuk meninjau PDF dan kode, mengimplementasikan form, menulis widget test, serta
menyusun dokumentasi dan menjalankan pemeriksaan teknis. Dua arahan yang saya
gunakan adalah “Kerjakan hanya scope Checkpoint 2 sesuai megaprompt utama” dan
“Jangan mengubah fitur yang sudah benar kecuali ditemukan bug.” Saya memisahkan
fondasi navigasi, validasi dan dialog, serta dokumentasi akhir agar hasil tiap
tahap dapat diperiksa sebelum commit berikutnya.

Runner widget test Codex terblokir oleh izin soket localhost. Saya menjalankan
uji di Terminal macOS dan menerapkan patch koreksi pengujian. Pada kasus 320×640,
test perlu menunggu SnackBar navigasi berakhir sebelum mensimulasikan papan ketik
dan memeriksa apakah tombol **Simpan** dapat diketuk. Terminal mencatat 33 test
lulus setelah koreksi. Saya menjalankan commit dan push CP1–CP2 melalui Terminal.
Hasil pengujian dan jejak progres tersedia di [laporan CP2](docs/tugas-8/PROGRESS_2.md)
dan [laporan akhir](docs/tugas-8/FINAL_REPORT.md).

## AI Usage Disclosure

Bagian ini mencatat penggunaan AI pada Tugas 7 dan Tutorial 09.

### Tools yang Digunakan

- **ChatGPT Website** — diskusi konsep Flutter/Dart, pemahaman requirement, dan
  penyusunan rencana tiga checkpoint serta prompt kerja.
- **OpenCode dengan model DeepSeek V4.1 Flash** — inspeksi repository, perubahan kode,
  pembuatan test, `flutter analyze`, `flutter test`, `flutter build web`, verifikasi
  browser melalui Playwright, termasuk implementasi Tutorial 09, dan penyusunan
  dokumentasi progres.
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
  dan `FittedBox(scaleDown)`. Pada Tutorial 09, header drawer dan dropdown kategori
  juga memerlukan penyesuaian (`FittedBox` dan `isExpanded`) agar tidak overflow.
- Kandidat warna deep orange 800 (`#D84315`) ditolak karena kontras putih hanya 4.44:1;
  diganti deep orange 900 (`#BF360C`) dengan 5.60:1.
- Widget test memakai font Ahem yang metriknya berbeda dari browser; hasil test tidak
  otomatis membuktikan tampilan perangkat nyata. Karena itu runtime browser juga diuji.
- Verifikasi browser memakai Chromium web, bukan Android/iOS. Klaim runtime mobile
  native tidak dibuat.
- Hasil yang dilaporkan agen didasarkan pada perintah yang benar-benar dijalankan;
  tidak ada percakapan, tautan, atau hasil test yang difabrikasi.

## Keterbatasan

- Belum ada integrasi API DRF atau autentikasi. Navigasi dan form bersifat lokal;
  tombol Logout hanya menampilkan SnackBar.
- Data form proyek hanya ditampilkan pada `AlertDialog` dan tidak disimpan ke
  database, file, atau API.
- Android emulator dan perangkat fisik belum dijalankan; iOS belum diverifikasi karena
  warning Xcode/CocoaPods.
- Verifikasi visual dilakukan pada Chromium web (Playwright), bukan window Chrome
  interaktif atau perangkat native.
- NPM dapat terbungkus beberapa baris pada layar 320–390 px, tetapi tetap terbaca
  lengkap dan tidak overflow.
- Commit Tutorial 09 tersedia di [`53ba8df`](https://github.com/glennjosia7/myportofolio_mobile/commit/53ba8df25863601d6aa81501cae8579747f2ab0b).

## Repository

```text
https://github.com/glennjosia7/myportofolio_mobile
git@github.com:glennjosia7/myportofolio_mobile.git
```

Repositori harus tetap publik. Submisi SCELE menggunakan tautan commit final, bukan
tautan halaman repository. Tenggat Tutorial 09 adalah 18 November 2026 pukul
23.59 WIB. Tenggat Tugas 8 adalah 23 November 2026 pukul 23.59 WIB.

## Tutorial 10 — Integrasi Django REST Framework

**Lihat Proyek** membuka daftar publik dari Django. Daftar mendukung refresh,
retry, dan layar detail. **Tambah Proyek** meminta login jika diperlukan. Form
memakai lima isian `ProjectSerializer` dan menampilkan ringkasan dari respons
`201 Created`. POST tetap hanya untuk superuser. Tautan proyek dan gambar
opsional sesuai model Django, dan jika diisi diperiksa sebagai URL HTTP/HTTPS.
Form Sertifikasi Tugas 8 tetap lokal.

`lib/models/project.dart` memakai `json_serializable`. `ApiClient` mengirim JSON
ke `/api/v1/projects/`, `/api/v1/auth/token/`, dan `/api/v1/auth/logout/`.
`MultiProvider` menyediakan `ApiClient` dan `AuthState`. Token disimpan di memori
selama aplikasi berjalan. Logout menghapus token lokal dan meminta backend
mencabutnya. Kesalahan jaringan saat logout diberitahukan lewat SnackBar.

### Menjalankan integrasi lokal

Terapkan perubahan backend Tutorial 10 di repo Django, pasang dependensi, lalu
jalankan migrasi dan server lokal:

```bash
python -m pip install -r requirements.txt
python manage.py migrate
python manage.py runserver 127.0.0.1:8000
```

Di repo Flutter:

```bash
flutter pub get
dart run build_runner build
flutter analyze
flutter test
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000
```

`project.g.dart` dibuat oleh generator dan diabaikan oleh Git. Commit
`pubspec.lock` setelah resolusi dependensi berhasil. Emulator Android memakai
`http://10.0.2.2:8000` sebagai alamat host secara default. Cleartext HTTP
Android hanya diaktifkan pada build debug. Untuk APK release gunakan backend
HTTPS dan `flutter build apk --release --dart-define=API_BASE_URL=https://alamat-backend`.

Workflow `.github/workflows/main.yaml` menjalankan format, analisis, dan test
sebelum membangun APK release. Kedua job menjalankan code generation. Isi variabel
repository `API_BASE_URL` dengan URL HTTPS deployment bila APK akan terhubung ke
backend di luar pengembangan lokal. Setelah push, periksa job `build` dan
`build_apk` serta unduh artefak `app-release-apk` dari tab Actions.
Lihat [laporan Tutorial 10](docs/tutorial-10/FINAL_REPORT.md) untuk status verifikasi.

## Assignment 9 — Integrasi Sertifikasi, Autentikasi Token & CI/CD

Assignment 9 menerapkan pola integrasi DRF, autentikasi token, dan CI/CD ke fitur
**Certifications** tanpa mengubah fungsionalitas **Projects** dan form lokal
sebelumnya:

- `lib/models/certification.dart` memetakan payload JSON DRF melalui
  `@JsonSerializable(fieldRename: FieldRename.snake)` dengan `@JsonKey(includeToJson: false)`
  pada `int? id`, tanggal bertipe `String` (`YYYY-MM-DD`), dan `expirationDate`
  opsional (`String?`, default `null`).
- `ApiClient` memperluas `/api/v1/certifications/` lewat `getCertifications()`
  (GET publik tanpa `Authorization`) dan `createCertification()` (POST bertoken
  `Authorization: Token <key>`).
- `CertificationListScreen` menampilkan daftar publik dengan `FutureBuilder`
  yang diinisialisasi di `initState()`, dukungan `RefreshIndicator`, tombol
  `Muat ulang`, dan pemulihan error `Coba lagi`, sedangkan `CertificationDetailScreen`
  menampilkan seluruh 6 field sertifikasi.
- `CertificationFormPage` menjaga pembukaan dan pengiriman formulir melalui
  `ensureLoggedIn(context)`, menangani `401 Unauthorized` dengan mencabut sesi
  lokal dan meminta login ulang tanpa auto-replay, serta menjaga sesi dan isian
  pada error `403`, `400`, maupun jaringan.
- Ringkasan progres dan QC tercatat di [progres Tugas 9](docs/tugas-9/PROGRESS.md),
  [laporan QC CP4](docs/tugas-9/QC_REPORT.md), dan
  [laporan akhir Tugas 9](docs/tugas-9/FINAL_REPORT.md).

### Instruksi Setup Assignment 9

1. Clone repositori Flutter publik:

   ```bash
   git clone https://github.com/glennjosia7/myportofolio_mobile.git
   cd myportofolio_mobile
   ```

2. Pastikan SDK sesuai versi terverifikasi proyek: **Flutter 3.47.9** (`stable`)
   dan **Dart 3.13.7** (`pubspec.yaml`: `sdk: ^3.13.7`), serta Python dan Django
   untuk backend lokal.
3. Pasang dependensi Flutter:

   ```bash
   flutter pub get
   ```

4. Jalankan generator JSON (`project.g.dart` dan `certification.g.dart`):

   ```bash
   dart run build_runner build
   ```

   Catatan: `build_runner` `2.17.1` pada lockfile mengabaikan/menghapus flag lama
   `--delete-conflicting-outputs`. Berkas `*.g.dart` tetap diabaikan oleh
   `.gitignore` dan `analysis_options.yaml`.

5. Siapkan backend Django dari repositori publik dan commit Assignment 9:
   - Repositori backend: `https://github.com/glennjosia7/myportofolio`
   - Commit Assignment 9 backend (`ProjectTokenAuthentication` pada
     `certification_list` `/api/v1/certifications/`):
     `https://github.com/glennjosia7/myportofolio/commit/410287ed49cdc5950062e3ca55545d9f36c57ff3`
   - Status deployment: URL PWS (`https://glenn-josia-myportofolio.pws.cs.ui.ac.id/api/v1/certifications/`)
     mengembalikan `HTTP 404` karena belum di-redeploy untuk endpoint API
     Assignment 9. Pengujian end-to-end dijalankan terhadap backend lokal dari
     commit referensi di atas.

6. Jalankan server Django lokal secara portabel (buat akun uji lokal dengan
   `manage.py createsuperuser` bila diperlukan, tanpa menyimpan kredensial di repo):

   ```bash
   git clone https://github.com/glennjosia7/myportofolio.git
   cd myportofolio
   python3 -m pip install -r requirements.txt
   PRODUCTION=False DEBUG=True python manage.py migrate
   PRODUCTION=False DEBUG=True python manage.py runserver 127.0.0.1:8000
   ```

7. Jalankan target Flutter Web:

   ```bash
   flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000
   ```

8. Jalankan pada emulator Android:
   Default `lib/config.dart` memakai `http://10.0.2.2:8000`, namun `ALLOWED_HOSTS`
   bawaan `portofolio/settings.py` backend hanya mencantumkan host PWS,
   `localhost`, dan `127.0.0.1` (sehingga host `10.0.2.2` ditolak `400 Bad Request`).
   Agar terhubung ke backend lokal tanpa memodifikasi pengaturan Django, gunakan
   penerusan port `adb reverse`:

   ```bash
   adb reverse tcp:8000 tcp:8000
   flutter run -d <device-id> --dart-define=API_BASE_URL=http://127.0.0.1:8000
   ```

   Cleartext HTTP Android hanya diaktifkan pada manifest debug; build release
   wajib menggunakan URL backend HTTPS.

9. Konfigurasi `API_BASE_URL`:
   Suntikkan alamat backend saat build atau run melalui
   `--dart-define=API_BASE_URL=<url-backend>`, atau atur variabel repositori
   GitHub Actions `API_BASE_URL` sebelum membangun APK release CI untuk backend HTTPS.
10. Jalankan pemeriksaan format, analisis statis, dan pengujian otomatis:

    ```bash
    dart format --output=none --set-exit-if-changed lib test
    flutter analyze
    flutter test
    ```

11. Bangun APK release secara lokal atau unduh artefak CI:

    ```bash
    flutter build apk --release --dart-define=API_BASE_URL=https://<backend-https-anda>
    ```

    Hasil lokal tersimpan di `build/app/outputs/flutter-apk/app-release.apk`, dan
    workflow GitHub Actions `.github/workflows/main.yaml` mengunggah artefak
    `app-release-apk` dari job `build_apk`.

### Assignment 9

1. Anotasi `@JsonSerializable(fieldRename: FieldRename.snake)` dan `@JsonKey(includeToJson: false)`
   pada `Certification` (`lib/models/certification.dart`) memberi contract JSON
   yang bertipe kuat antara Dart dan `CertificationSerializer` di Django DRF:
   properti camelCase Dart (`issuingOrganization`, `issueDate`, `expirationDate`,
   `credentialId`, `credentialUrl`) otomatis dipetakan ke key `snake_case` DRF,
   field `int? id` tetap dapat dibaca dari respons server (`BigAutoField`) namun
   dikecualikan saat `toJson()` untuk `POST`, tanggal terbit disimpan dalam format
   date-only `YYYY-MM-DD`, serta `expirationDate` bertipe nullable `String?` dengan
   default `null` dan metadata baca tambahan (`star_count`, `is_starred`,
   `starred_by_names`) diabaikan dengan aman oleh kode hasil `certification.g.dart`.
   Jika widget langsung menyusun `Map<String, dynamic>` mentah, satu typo kecil
   seperti mengirim `'issuingOrganization'` alih-alih `'issuing_organization'`,
   menyertakan `'id': null`, atau mengirim string tanggal berformat lokal UI akan
   memicu kegagalan validasi `400 Bad Request` pada DRF maupun menyebabkan field
   opsional kedaluwarsa tidak tersimpan konsisten. Pembangkitan `toJson()`
   mencegah kelas bug penyimpangan kontrak payload tersebut sebelum kompilasi.

2. Memanggil sumber data di dalam `build()` berisiko besar karena `build()`
   dipanggil ulang setiap kali ada perubahan state UI, kemunculan papan ketik,
   atau pembaruan `MediaQuery`/`InheritedWidget`. Bila `getCertifications()`
   dijalankan langsung di `build()`, setiap rebuild akan mengirim permintaan HTTP
   `GET` berulang ke Django dan menciptakan `Future` baru yang memaksa
   `FutureBuilder` mengulang status loading. Pada `CertificationListScreen`,
   `_certifications` diinisialisasi satu kali di `initState()` dan baru diperbarui
   secara eksplisit pada `_refresh()` (dipanggil oleh `RefreshIndicator`, tombol
   app bar `Muat ulang`, dan tombol `Coba lagi`) melalui assignment sinkron di
   dalam `setState()` dengan `await` di luar `setState()`. Sementara itu,
   `ApiClient` melempar `ApiException(message, statusCode: response.statusCode)`
   pada respons non-2xx atau kegagalan jaringan daripada mengembalikan `null`,
   supaya UI dapat membedakan daftar yang sah-sah saja kosong (`200 []` -> pesan
   `'Belum ada sertifikasi.'`) dari kegagalan jaringan/server (menampilkan pesan
   `ApiException` dan aksi `Coba lagi`). Di `CertificationFormPage`, adanya
   `statusCode` juga memungkinkan percabangan spesifik: `401` memanggil
   `auth.invalidate(token)` lalu meminta login ulang, sedangkan `403`, `400`, dan
   error jaringan menjaga sesi serta isian form sambil menampilkan `SnackBar`.

3. `SessionAuthentication` Django memanfaatkan cookie sesi berbasis browser dan
   wajib memvalidasi token CSRF pada permintaan tulis browser, sedangkan
   `TokenAuthentication` DRF (pada `ProjectTokenAuthentication` yang mewarisi
   `TokenAuthentication`) mengautentikasi setiap permintaan secara stateless
   melalui header `Authorization: Token <key>` tanpa bergantung pada cookie atau
   CSRF sehingga lebih portabel untuk klien Flutter Web maupun Android native. Pada
   `myportofolio_mobile`, `AuthState` menyimpan token di memori selama sesi
   berlangsung, mencabut token di backend melalui `POST /api/v1/auth/logout/`
   (`204 No Content`), dan saat menerima HTTP `401` langsung membersihkan token
   lokal lewat `auth.invalidate(token)` serta meminta login ulang tanpa auto-replay
   `POST`. Di backend (`main/api_views.py` commit `410287e`), decorator
   `@authentication_classes([ProjectTokenAuthentication, SessionAuthentication])`
   mempertahankan kedua skema secara berdampingan agar klien browser situs web
   Django beserta proteksi CSRF-nya tetap kompatibel, sementara klien mobile dapat
   mengirimkan token. Kebijakan otorisasi `IsPortfolioOwnerOrEditorOrReadOnly`
   tetap terpisah dari autentikasi: token dicabut/tidak sah ditolak pada tahap
   autentikasi dengan `401 Unauthorized`, sedangkan akun terautentikasi yang bukan
   `is_superuser` (termasuk user biasa dan grup `Editor` yang hanya memiliki izin
   `PUT`/`PATCH` detail) tetap mendapat `403 Forbidden` saat mencoba `POST`.

4. Pada `.github/workflows/main.yaml`, job `build` memakai reusable workflow
   `VeryGoodOpenSource/very_good_workflows/.github/workflows/flutter_package.yml@v2`
   (dipicu oleh `push` ke `main` dan `pull_request`, menggunakan Flutter `3.47.9`,
   `setup: dart run build_runner build`, `coverage_excludes: '**/*.g.dart'`, dan
   `min_coverage: 0`). Pemeriksaan aktual yang dijalankan oleh reusable workflow
   pada run CI kami mencakup checkout repositori, setup Flutter, instalasi
   dependensi (`flutter pub get`), eksekusi setup generator (`dart run build_runner build`),
   pemeriksaan format, `flutter analyze`, resolusi `dart define`, dan eksekusi
   `flutter test` (langkah Bloc Lint, Cognitive Complexity, dan Upload Artifacts
   dilewati sesuai konfigurasi). Job `build_apk` memakai `needs: build` sehingga
   baru berjalan bila seluruh pemeriksaan kualitas `build` lulus; ia membangun ulang
   file `*.g.dart`, menjalankan `flutter build apk --release` (dengan
   `--dart-define="API_BASE_URL=$API_BASE_URL"` jika variabel repositori diatur),
   dan mengunggah `build/app/outputs/flutter-apk/app-release.apk` sebagai artefak
   `app-release-apk`. Berkas `*.g.dart` dikecualikan lewat `.gitignore` (serta
   `analysis_options.yaml`) karena merupakan artefak deterministik turunan
   anotasi `@JsonSerializable`: mengabaikannya menjaga diff Git tetap bersih,
   menghindari konflik merge, dan memastikan setiap lingkungan CI maupun pengembang
   meregenerasi serializer terbaru langsung dari definisi model.

#### Penggunaan AI Assignment 9

Pengerjaan Assignment 9 dilakukan secara bertahap dalam 5 checkpoint menggunakan
alat berikut secara transparan:

- **Alat yang digunakan:** **ChatGPT Website** untuk interpretasi checklist PDF,
  perancangan strategi 5 checkpoint, penyusunan megaprompt, dan pemecahan kendala
  Git; **Antigravity** (orkestrasi dan perencanaan pada **Gemini 4 Neon XHigh**,
  bantuan eksekusi pada **Gemini 4 Hydrogen XHigh**) untuk analisis repo, audit
  kontrak Django-Flutter, implementasi, pengujian otomatis, QC independen, dan
  penyusunan dokumentasi.
- **Strategi prompting dan verifikasi:** Memecah pekerjaan menjadi CP1 (model JSON),
  CP2 (API client & baca publik), CP3 (form terautentikasi & perbaikan
  `ProjectTokenAuthentication` backend), CP4 (pengujian lanjutan, QC subagent,
  adaptasi persona `mobile-agent-testers` SHA `494a15b`, E2E headless Chrome CDP
  27 skenario, dan audit CORS), serta CP5 (quality gate akhir, build APK lokal,
  smoke emulator Android headless `adb reverse`, README, dan laporan final).
- **Keterbatasan AI dan koreksi manual mahasiswa:**
  - Tiga perintah `git add` multi-baris yang dihasilkan AI pada CP2–CP4 tidak
    memiliki karakter sambung baris (`\`), sehingga beberapa berkas test maupun
    perbaikan sempat tertinggal pada commit awal dan harus dilengkapi mahasiswa
    melalui commit korektif (`1d2475b`, `d6bc863`, `2783432`) sebelum riwayat
    CP5 diserahkan.
  - Repositori `mobile-agent-testers` tidak dijalankan dengan `setup.sh` / runner
    GitHub Actions asli karena memerlukan kredensial Claude Code dan tidak dapat
    mengakses server Django lokal (`127.0.0.1`); hanya taksonomi persona berlisensi
    MIT yang diadaptasi ke subagent riset dan otomasi Chrome CDP lokal.
  - Pada E2E headless Chrome, pembacaan nilai DOM `.value` dari input Flutter Web
    yang tidak sedang fokus mengembalikan string kosong; keterbatasan skrip E2E
    tersebut dikompensasi oleh bukti pengiriman ulang langsung (`E22`) tanpa
    mengetik ulang setelah `401` dan assertion eksplisit pada 6 field di widget test.
  - Pada uji emulator Android, alamat default `10.0.2.2` ditolak `400 Bad Request`
    oleh `ALLOWED_HOSTS` Django sehingga diverifikasi melalui `adb reverse tcp:8000 tcp:8000`
    dengan `127.0.0.1:8000` tanpa memodifikasi konfigurasi keamanan backend.
  - Seluruh keputusan akhir, eksekusi Git, dan pengumpulan ke SCELE dilakukan
    secara manual oleh mahasiswa; tidak ada klaim bahwa seluruh kode ditulis
    manual, tidak ada tautan percakapan AI yang dibuat-buat, dan tidak ada
    kredensial yang disimpan ke repositori.
