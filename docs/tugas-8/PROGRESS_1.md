# Tugas 8 — Checkpoint 1

## A. Executive Summary

Fondasi Form Sertifikasi, kartu aksi, dan navigasi drawer sudah diterapkan di
repo Flutter. Analyzer dan build web lulus. Runner widget test terhalang izin
soket localhost sebelum menjalankan satu pun test.

## B. Audit PDF dan sumber

Keempat halaman PDF Tugas 8 diperiksa. Rubrik memberi bobot 70% untuk
fungsionalitas, 10% kualitas kode, 10% disiplin Git, dan 10% dokumentasi serta
AI disclosure. PDF Tutorial 09 yang berisi 27 halaman diperiksa bersama README,
semua file `lib/`, suite widget test, `pubspec.yaml`, dan riwayat Git.
Navigasi dan tampilan baru mengikuti struktur `screens/` dan `widgets/`
serta penggunaan `material_ui` dari Tutorial 09.

### Model Certification

Sumber model adalah `myportofolio/main/models.py` pada proyek Django. Form dan
serializer Django juga diperiksa untuk membedakan constraint model dan
pembersihan input di lapisan aplikasi.

| Field | Tipe dan constraint | Cakupan |
|---|---|---|
| `name` | `CharField` wajib, maksimal 255 karakter | Nama Sertifikasi |
| `issuing_organization` | `CharField` wajib, maksimal 255 karakter | Lembaga Penerbit |
| `credential_id` | `CharField` wajib, maksimal 255 karakter | ID Kredensial |
| `issue_date` | `DateField` wajib | Checkpoint 2 |
| `expiration_date` | `DateField` opsional dengan `blank=True, null=True` | Checkpoint 2 |
| `credential_url` | `URLField` wajib, batas bawaan Django 200 karakter | Checkpoint 2 |
| `id`, `starred_by` | Primary key otomatis dan relasi opsional ke pengguna | Di luar formulir |

Model tidak menetapkan aturan urutan tanggal. Form dan serializer Django
merapikan spasi dan menghapus tag dari tiga field teks, serta menolak nama
yang kosong sesudah pembersihan. Checkpoint 2 menambahkan validasi input
mobile dan pemeriksaan urutan tanggal sesuai arahan tugas.

## C. Baseline repository

`main` dan remote-tracking ref `origin/main` sama-sama menunjuk
`53ba8df25863601d6aa81501cae8579747f2ab0b`, commit Tutorial 09.
Reflog merekam `update by push` pada 17 November 2026 pukul 20.26.33 WIB,
sebelum tenggat Tutorial 09. Cek langsung ke GitHub via SSH dan HTTPS
terhalang DNS. Status repo asli bersih.

## D. Compliance matrix

| Persyaratan | Status | Bukti |
|---|---|---|
| Form terpisah, stateful, dan tiga input relevan | Terimplementasi | `CertificationFormPage`, `GlobalKey<FormState>`, tiga `TextFormField` |
| Kartu aksi dan drawer bersama | Terimplementasi | `MyHomePage.items`, `ItemCard`, `LeftDrawer` |
| Home dan Back kembali ke halaman utama | Terimplementasi, pengujian runtime tertunda | Logika stack `LeftDrawer` dan widget test |
| Validasi, pemilih tanggal, Simpan, dan ringkasan | Dijadwalkan di Checkpoint 2 | Tercatat di bagian L |
| Refleksi README dan AI disclosure | Dijadwalkan di Checkpoint 3 | README Tutorial 09 dipertahankan |
| Commit dan push | Terblokir | Widget test belum berjalan dan akses tulis `.git` ditolak |

## E. Perubahan

Kartu Tambah Sertifikasi memakai ikon sertifikat dan warna ungu
`#6A1B9A` dengan kontras teks putih 9,39:1. `ItemCard` mengambil
tujuan navigasi dari model kartu, mempertahankan SnackBar dan memakai
`Navigator.push()` saat tujuan tersedia. Drawer menutup panel sebelum
berpindah. Home dipertahankan sebagai rute dasar. Berpindah antarform
mengganti rute form teratas dan memilih form aktif mempertahankan isiannya.

## F. Validasi

Checkpoint 1 menyediakan input dasar yang dapat diedit. Validasi
panjang, isian wajib, URL, dan tanggal dikerjakan di Checkpoint 2.

## G. Hasil pengujian

Pemeriksaan Checkpoint 1 dijalankan di repo Flutter memakai salinan SDK
Flutter 3.47.9 dan Dart 3.13.7. SDK bawaan gagal menulis cache dan `flutter pub get`
dihentikan saat masih menyelesaikan dependensi. Mode offline berhasil memakai
cache paket yang tersedia.

| Pemeriksaan | Baseline | Checkpoint 1 |
|---|---|---|
| `flutter pub get --offline` | PASS, dependency terselesaikan | PASS, lockfile sama |
| `flutter analyze --no-pub` | PASS, no issues found | PASS, no issues found |
| `flutter test --no-pub --reporter expanded` | Terblokir sebelum test berjalan | Terblokir, 0 dari 24 test berjalan |
| `flutter build web --no-pub` | PASS, `Built build/web` | PASS, `Built build/web` |
| `git diff --check` | Tidak berlaku | PASS |
| `dart format` untuk berkas Dart yang diubah | Tidak dijalankan | PASS, 5 berkas, 0 perubahan |
| `git apply --check --whitespace=error-all` | Tidak berlaku | PASS terhadap repo asli |

Flutter test gagal membuka soket di `127.0.0.1:0` dengan
`Operation not permitted`. Ke-20 test lama dipertahankan, dengan ekspektasi
jumlah dan elemen menu diperbarui sesuai fitur. Empat test tambahan mencakup
kartu dan tiga input pada 320×640, Add Certification dan Home, perpindahan
antarform serta Back, dan retensi input pada form aktif.

## H. Browser QA

Belum diuji di browser. Build web memverifikasi kompilasi aplikasi.

## I. File yang berubah

- `lib/screens/certification_form.dart`
- `lib/screens/menu.dart`
- `lib/widgets/project_card.dart`
- `lib/widgets/left_drawer.dart`
- `test/widget_test.dart`
- `docs/tugas-8/PROGRESS_1.md`

## J. Keterbatasan

Form masih bersifat lokal. Fitur ini tidak menambah API, penyimpanan,
atau dependency. Kode Django dipakai sebagai acuan baca saja.
Folder kerja repo Flutter dapat ditulis. Direktori `.git` dan cache SDK
bawaan menolak akses tulis.

## K. Audit Git

- Remote `git@github.com:glennjosia7/myportofolio_mobile.git`
- Branch `main`
- Identitas `DevCoder-7 <177463070+DevCoder-7@users.noreply.github.com>`
- Keenam file Checkpoint 1 berubah di folder kerja dan belum di-stage
- GitHub via SSH terhalang DNS untuk `ssh.github.com`
- Usulan commit `feat(flutter): scaffold certification form and navigation`

## L. Checkpoint berikutnya

Jalankan widget test pada lingkungan yang mengizinkan soket localhost.
Setelah Checkpoint 1 di-commit dan di-push, lanjutkan hanya atas instruksi
eksplisit. Checkpoint 2 mencakup field URL dan tanggal, pemilih tanggal,
validasi, tombol Simpan, ringkasan seluruh nilai, dan pengujian responsif.

## M. Verdict

Checkpoint 1 terimplementasi di repo Flutter. Status quality gate masih
terbuka sampai widget test berjalan dan lulus. Commit memerlukan akses
tulis ke `.git`, dan verifikasi push memerlukan koneksi ke GitHub.
