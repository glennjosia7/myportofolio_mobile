# PBP Tutorial 10 — Integrasi Flutter, DRF, dan CI/CD

Glenn Josia Devano · NPM 2506614712 · PBP F

## Ringkasan

Implementasi Flutter dan backend berada di working tree masing-masing.
Terminal macOS mencatat Django 107/107, Flutter 32/32 pada dua file fokus, dan
Flutter 45/45 pada suite penuh. Preflight lulus melalui test client pada repo
Django asli. HTTP live, browser E2E, dan build APK masih terbuka.

## Sumber dan baseline

PDF Tutorial 10 halaman 1–20 dan megaprompt pelaksanaan ditinjau. Audit kode
mencakup pengaturan dan routing Django, view API, serializer, model, permission,
test, serta Flutter `lib/`, `test/`, manifest Android, dan laporan sebelumnya.

| Repo | Branch dan baseline | Remote |
|---|---|---|
| `myportofolio` di direktori induk repo Flutter | `main` · `bfddf57` | `git@github.com:glennjosia7/myportofolio.git` |
| `myportofolio_mobile` | `main` · `e94890d` | `git@github.com:glennjosia7/myportofolio_mobile.git` |

Django punya tiga penghapusan dokumen Tugas 6 dari sebelum pekerjaan ini.
Ketiganya dipertahankan dan tidak disertakan dalam patch. Git Flutter awal
bersih. Kedua ref lokal `origin/main` cocok dengan `HEAD` masing-masing.
Identitas Git `DevCoder-7`. Baseline Django 5.2.18 lulus `check`, migrasi SQLite
sementara, `migrate --check`, dan 101 test. Baseline Flutter 3.47.9/Dart 3.13.7
lulus analyzer dan build web. Runner widget test baseline terblokir oleh izin
soket localhost.

## Backend, kontrak API, dan keamanan

Patch menambahkan `django-cors-headers`, `rest_framework.authtoken`, konfigurasi
CORS per origin, login token, dan logout yang menghapus token pemanggil. CORS
lokal memakai origin loopback di mode pengembangan. Produksi perlu daftar
origin tepercaya melalui `CORS_ALLOWED_ORIGINS`. Perlindungan CSRF dan autentikasi
sesi lama tetap berlaku. Flutter hanya memakai token untuk mutasi Projects dan
logout. GET publik tidak mengirim token. Anonymous POST tetap 403 sesuai kontrak
lama, header Token yang invalid memberi 401, dan token akun biasa atau Editor
tetap mendapat 403 saat POST. Token dan password tidak ditulis ke log aplikasi.
Gunakan HTTPS untuk backend di luar lingkungan pengembangan lokal.

`ProjectSerializer` mengembalikan UUID dan metadata star. Klien mengabaikan
metadata tambahan dan tidak mengirim UUID dalam POST. Title, description, dan
tech stack wajib. Kedua URL opsional mengikuti `blank=True` pada model Django.
Kategori dari simulasi Tutorial 09 digantikan URL gambar karena API tidak punya
field kategori. Certification API dan form Tugas 8 tetap pada lingkup sebelumnya.

## Flutter dan pipeline

`ApiClient` memakai `http.Client` yang dapat diinjeksi, batas waktu,
`ApiException`, dan decoding UTF-8. `FutureBuilder` memakai Future dari
`initState`, dengan retry, pull-to-refresh untuk keadaan kosong/berisi, dan
navigasi detail. Gambar eksternal hanya dimuat untuk URL HTTP/HTTPS dengan
fallback jika tidak dapat dimuat. Drawer dan kartu mengarahkan tindakan
Tambah Proyek melalui login. Form memvalidasi dan mengirim POST, membedakan
401 dari 403, mempertahankan isian saat gagal, dan menampilkan ringkasan dari
respons 201. Log out selalu membersihkan token lokal, termasuk saat permintaan
pencabutan token gagal. Provider memegang sesi di memori.

Workflow menjalankan reusable Flutter CI `@v2` dan `build_apk` setelah `build`.
Keduanya memakai Flutter 3.47.9 dan `dart run build_runner build`. Opsi
`--delete-conflicting-outputs` dihapus karena Build Runner 2.17.1 sudah
mengabaikannya. Versi SDK memenuhi batas lockfile, yaitu Flutter ≥3.47.0 dan
Dart ≥3.13.7. Sintaks YAML dan dependensi job diperiksa lokal.
Status remote Actions dan artefak APK menunggu push pengguna dan eksekusi nyata.

## Recovery dan penyebab kegagalan

- Pada macOS Terminal, `flutter pub get`, code generation, format, analyzer,
  dan build web lulus sebelum koreksi. Lockfile dan cache mengonfirmasi
  `http` 1.6.0, `provider` 6.1.5+1, `json_annotation` 4.12.0, `build_runner` 2.17.1,
  dan `json_serializable` 6.15.2. `project.g.dart` ada, diabaikan Git,
  menangani URL kosong, dan mengecualikan UUID dari JSON POST.
- Suite Terminal sebelum koreksi menghasilkan 34 lulus dan delapan gagal dari
  42 test. Satu gagal karena `_refresh()` mengembalikan hasil assignment bertipe
  `Future` dari callback `setState`. Assignment kini berlangsung dalam blok
  sinkron dan permintaan ditunggu di luar callback.
- Tujuh gagal saat tap **Save**. Helper lama menunggu animasi selesai, sedangkan
  SnackBar navigasi masih tampil dan dapat menutup area tombol. Helper sekarang
  menunggu SnackBar berakhir, menggulir tombol ke posisi terlihat, memeriksa bahwa
  tombol aktif dan hit-testable, lalu mengetuknya. Layout aplikasi dipertahankan.
- Test form kini mencatat POST aktual pada mock HTTP, memeriksa jumlah, payload,
  token fixture, 401/403/201, dan menguji dialog dengan nilai yang dikirim server.
  Test input invalid mengharapkan nol POST. Pemeriksaan viewport lama diperluas
  ke 320, 390, 768, dan 1280 piksel. Target suite sekarang 45 kasus.
- Uji fokus berikutnya dari Terminal menunjukkan `Guarded function conflict`
  saat callback `MockClient` menjalankan `expect()` selama `pumpAndSettle()`.
  Gesture tarik sudah memicu request ketiga, tetapi assertion di callback
  menghentikannya sebelum pencatatan. Mock daftar dan form kini mencatat request.
  Assertion metode, header, payload, dan jumlah request dijalankan di badan test
  setelah aksi UI selesai. Uji ulang di Terminal macOS pada 24 November 2026
  pukul 11.21 WIB lulus 32/32 test fokus dan 45/45 test penuh.

## Bukti pengujian

| Pemeriksaan | Hasil aktual |
|---|---|
| Django patch dan dependensi | PASS. Patch terpasang melalui Terminal macOS. Reverse apply check lulus pada repo asli. `.venv/bin/python` menjalankan Python 3.14.8, Django 5.2.18, dan `django-cors-headers` 4.9.0 |
| Django system check, migrasi, model, dan test | PASS menurut output Terminal macOS pada repo asli. Empat migrasi authtoken lulus, schema tidak berubah, dan 107/107 test lulus dalam 25,104 detik. Hasil terdahulu 106 test berasal dari salinan tanpa CORS |
| Django CORS dan Projects melalui test client | PASS pada repo asli. Preflight 200 untuk `localhost` dan `127.0.0.1`, mengizinkan `POST`, `Authorization`, dan `Content-Type`. Origin asing tidak mendapat izin. Pada mode produksi, loopback ditolak dan origin HTTPS dalam allowlist diizinkan. GET anonim 200 dengan array kosong dan POST anonim 403 |
| CORS HTTP live | BLOCKED. `curl` tidak dapat terhubung ke `127.0.0.1:8000`. Bind loopback ditolak dengan `Operation not permitted` |
| Flutter `flutter pub get` dan code generation | PASS di Terminal sebelum koreksi. Build Runner 2.17.1 `build --only-check` lulus saat recovery. Uji Dart terpisah lulus untuk serialisasi, GET publik, header dan payload POST, serta UTF-8 dengan `MockClient` |
| Flutter `dart format --output=none --set-exit-if-changed lib test` | PASS, 19 file, 0 perubahan setelah koreksi |
| Flutter `flutter analyze --no-pub` | PASS setelah koreksi, `No issues found!` |
| Flutter `flutter test --no-pub` untuk dua file fokus dan seluruh suite | PASS di Terminal macOS setelah koreksi, 32/32 fokus dan 45/45 penuh. Termasuk regresi Sertifikasi dan test pada empat viewport. Runner sandbox sebelumnya tertahan oleh izin soket `127.0.0.1:0` |
| Flutter `flutter build web --no-pub --dart-define=API_BASE_URL=http://localhost:8000` | PASS, `Built build/web` |
| Flutter `flutter build apk --no-pub --release` | BLOCKED. Gradle 9.3.1 sebelumnya gagal membuka file lock. Distribusi belum tersedia di cache dan `services.gradle.org` gagal di-resolve dalam sesi ini |
| Browser QA Django–Flutter | BLOCKED oleh bind loopback. Widget Flutter lulus pada lebar 320, 390, 768, dan 1280 px. Browser live, akun QA, dan proyek QA masih menunggu eksekusi |
| Android runtime | NOT TESTED |

## Matriks pemenuhan

| Gate | Status dan bukti |
|---|---|
| B01–B07, B09–B16 | PASS pada repo asli. Patch, paket CORS, migrasi, token, sesi, CSRF, izin, dan regresi Certification diverifikasi lewat suite 107 test dan pemeriksaan tambahan |
| B08 | PASS melalui test client. HTTP preflight live masih terblokir |
| F01, F04 | PASS di Terminal. Lockfile dan keluaran generator diperiksa |
| F02–F03, F05–F06 | PASS dalam audit konfigurasi analyzer, Git ignore, manifest, dan `API_BASE_URL` |
| F07–F15 | PASS pada suite Flutter dengan mock HTTP. Verifikasi terhadap Django asli masih terbuka |
| F16 | NOT TESTED untuk Flutter Web runtime |
| S01–S20 | PASS pada suite Flutter, termasuk refresh, Save, login, dan regresi Certification. Browser E2E masih terbuka |
| C01–C08 | PARTIAL. Workflow, trigger, input, regenerasi, urutan build, dan APK artifact didefinisikan. Eksekusi remote tertunda |
| C09 | PASS sintaks YAML dan relasi job |
| C10 | PARTIAL. Generator, format, analyzer, build web, dan 45 test Flutter lulus. APK terblokir |
| C11 | NOT TESTED. Belum ada push workflow |
| Q01–Q02 | PASS pada repo Django asli, system check bersih dan 107 test lulus |
| Q03 | PASS format Flutter |
| Q04–Q09 | PARTIAL. Analyzer, build web, dan 45 test Flutter lulus. Empat viewport teruji pada widget. APK dan browser E2E masih terbuka |
| Q10 | PASS dalam audit diff dan nama file yang berubah |
| Q11 | PASS. Regresi Certification lulus pada suite Django asli dan Flutter penuh |
| Q12–Q16 | PASS untuk dokumentasi, laporan, audit diff, tanpa operasi Git tulis oleh agen, dan panduan pengumpulan |

## Cakupan perubahan dan Git

Backend patch mencakup `requirements.txt`, `portofolio/settings.py`,
`main/api_urls.py`, `main/api_views.py`, `main/test_tutorial_10.py`, `README.md`,
dan `docs/tutorial-10/BACKEND_REPORT.md`. Flutter mencakup konfigurasi paket,
Android, dan workflow, aplikasi dan layanan Projects/auth di `lib/`, penyesuaian
regresi dan test baru di `test/`, serta README dan laporan ini. Recovery Stage 2
mengubah `lib/screens/project_list_screen.dart`, `test/widget_test.dart`,
`.github/workflows/main.yaml`, `README.md`, dan laporan ini. `pubspec.lock`
memuat resolusi dependensi dari Terminal. Audit akhir cocok dengan daftar staging
manual, yaitu 7 berkas Django dan 25 berkas Flutter. Index kedua repo kosong.
Tiga penghapusan docs Tugas 6 tetap di luar daftar staging. Pemeriksaan diff
dan pola kredensial umum tidak menemukan temuan. Tidak ada
staging, commit, push, deployment, atau pengumpulan SCELE oleh agen.

## Verifikasi dan pengumpulan manual

### Perbarui laporan backend

Patch implementasi sudah terpasang. Akses tulis sesi ini ke repo Django ditolak.
Di Terminal, terapkan patch dokumentasi berikut. Jika file sementara hilang,
gunakan [salinan patch laporan](https://chatgpt.com/library?file_id=libfile_311b1787c66081918b97d5607f46eca3&account_id=personal)
dan sesuaikan path.

```bash
cd "/Users/devanmacbook/Documents/01_Kuliah/MAIN_KULIAH/Semester-3/PBP/Tugas-Individu/Tugas-Individu/myportofolio" &&
patch=/tmp/pbp-t10.f4Eobw/Tutorial10_BACKEND_REPORT_update.patch &&
git apply --check --whitespace=error-all "$patch" &&
git apply --whitespace=error-all "$patch"
```

### Selesaikan HTTP live dan browser QA

Jalankan server berikut pada dua Terminal terpisah. Perintah Flutter memakai
`web-server`, sehingga Anda dapat memilih browser secara manual.

```bash
cd "/Users/devanmacbook/Documents/01_Kuliah/MAIN_KULIAH/Semester-3/PBP/Tugas-Individu/Tugas-Individu/myportofolio" &&
PRODUCTION=False DEBUG=True .venv/bin/python manage.py runserver 127.0.0.1:8000 --noreload
```

```bash
cd "/Users/devanmacbook/Documents/01_Kuliah/MAIN_KULIAH/Semester-3/PBP/Tugas-Individu/Tugas-Individu/myportofolio_mobile" &&
flutter run --no-pub -d web-server --web-hostname=127.0.0.1 --web-port=7357 \
  --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

```bash
for origin in http://127.0.0.1:7357 https://untrusted.example; do
  curl -sS -D - -o /dev/null -X OPTIONS http://127.0.0.1:8000/api/v1/projects/ \
    -H "Origin: $origin" -H 'Access-Control-Request-Method: POST' \
    -H 'Access-Control-Request-Headers: authorization,content-type'
done
curl -fsS -o /dev/null -w 'Anonymous GET %{http_code}\n' http://127.0.0.1:8000/api/v1/projects/
```

Ekspektasi live adalah GET 200. OPTIONS loopback 200 dengan `Access-Control-Allow-Origin`
yang persis sama dan header izin yang mencakup `authorization` serta `content-type`.
OPTIONS origin asing tidak mendapat `Access-Control-Allow-Origin`.

Siapkan tiga akun sementara di terminal backend. Password dimasukkan tanpa echo.
Simpan ID QA yang ditampilkan untuk nama proyek dan pembersihan.

```bash
PRODUCTION=False DEBUG=True DJANGO_SETTINGS_MODULE=portofolio.settings .venv/bin/python -B - <<'PYQA'
from getpass import getpass
from uuid import uuid4
import django

django.setup()
from django.contrib.auth import get_user_model
from django.contrib.auth.models import Permission
from django.db import transaction

password = getpass('Password akun QA sementara: ')
if not password:
    raise SystemExit('Password QA wajib diisi')
tag = uuid4().hex[:12]
owner, member, editor = (f't10qa_{tag}_{role}' for role in ('owner', 'member', 'editor'))
users = get_user_model().objects
with transaction.atomic():
    users.create_superuser(owner, password=password)
    users.create_user(member, password=password)
    editor_user = users.create_user(editor, password=password)
    editor_user.user_permissions.add(Permission.objects.get(content_type__app_label='main', codename='change_certification'))
print(f'ID QA: {tag}. Akun: {owner}, {member}, {editor}. Judul proyek: T10 QA {tag}')
PYQA
```

1. Buka `http://127.0.0.1:7357` di sesi browser QA terpisah. Klik **Lihat
   Proyek**. Pastikan GET 200 dan empty state atau data tampil. Uji Retry saat
   backend lokal sementara berhenti, lalu nyalakan lagi dan cek daftar kembali.
2. Sebagai anonim, pilih **Tambah Proyek** dan batalkan login. Pastikan form
   tidak terbuka. Coba password yang salah. Lalu login sebagai owner QA.
3. Buat satu proyek berjudul persis `T10 QA <ID QA>`. Pastikan POST 201, buka
   daftar, tarik untuk refresh, dan buka detail. Logout. Pastikan form proyek
   memerlukan login lagi. Suite Django memverifikasi token yang dicabut ditolak.
4. Login bergantian sebagai member dan Editor QA. Isi form dengan judul yang
   sama dan pastikan masing-masing POST ditolak dengan 403. Logout setiap kali.
5. Periksa form Sertifikasi dan navigasinya. Ulangi pemeriksaan tata letak pada
   lebar 320, 390, 768, dan 1280 px. Catat viewport browser secara terpisah dari
   hasil widget test. Pada mesin yang punya Gradle, jalankan
   `flutter build apk --no-pub --release` dari root Flutter.

Pembersihan hanya menyasar akun dan judul unik dari sesi QA ini. Jalankan dari
root Django dan ganti `ID_QA` menggunakan ID yang dicetak saat membuat akun.

```bash
QA_TAG=ID_QA PRODUCTION=False DEBUG=True DJANGO_SETTINGS_MODULE=portofolio.settings .venv/bin/python -B - <<'PYQA'
import os
import re
import django

tag = os.environ['QA_TAG']
if not re.fullmatch(r'[0-9a-f]{12}', tag):
    raise SystemExit('Masukkan ID QA yang dicetak sebelumnya')
django.setup()
from django.contrib.auth import get_user_model
from django.db import transaction
from main.models import Project

with transaction.atomic():
    Project.objects.filter(title=f'T10 QA {tag}').delete()
    get_user_model().objects.filter(username__in=[f't10qa_{tag}_{role}' for role in ('owner', 'member', 'editor')]).delete()
print('Pembersihan fixture QA selesai')
PYQA
```

Setelah push manual, cocokkan SHA dengan `git ls-remote origin refs/heads/main`
di kedua repo. Buka Actions untuk SHA Flutter, cek `build` dan `build_apk`, dan
unduh `app-release-apk` dari run yang sama. Gunakan URL commit Flutter untuk
SCELE. Tenggat Tutorial 10 adalah **25 November 2026, 23.59 WIB**.

Perintah staging berikut berlaku setelah verifikasi runtime selesai. Jalankan
setiap blok di repo yang disebutkan, dengan working tree yang sudah ditinjau.

```bash
# Repo Django myportofolio
cd "/Users/devanmacbook/Documents/01_Kuliah/MAIN_KULIAH/Semester-3/PBP/Tugas-Individu/Tugas-Individu/myportofolio"
git add -- requirements.txt portofolio/settings.py main/api_urls.py main/api_views.py \
  main/test_tutorial_10.py README.md docs/tutorial-10/BACKEND_REPORT.md
git diff --cached --check
git diff --cached --name-only
git commit -m "feat(api): add token authentication and Flutter CORS support"
git push origin main
```

```bash
# Repo Flutter myportofolio_mobile
cd "/Users/devanmacbook/Documents/01_Kuliah/MAIN_KULIAH/Semester-3/PBP/Tugas-Individu/Tugas-Individu/myportofolio_mobile"
git add -- .gitignore .github/workflows/main.yaml analysis_options.yaml \
  android/app/src/debug/AndroidManifest.xml android/app/src/main/AndroidManifest.xml \
  pubspec.yaml pubspec.lock README.md docs/tutorial-10/FINAL_REPORT.md \
  lib/config.dart lib/main.dart lib/models/project.dart \
  lib/screens/login_screen.dart lib/screens/menu.dart lib/screens/project_form.dart \
  lib/screens/project_list_screen.dart lib/screens/project_detail_screen.dart \
  lib/services/api_client.dart lib/services/auth_state.dart lib/widgets/auth_guard.dart \
  lib/widgets/left_drawer.dart lib/widgets/project_card.dart \
  test/widget_test.dart test/project_list_test.dart test/tutorial_10_api_test.dart
git diff --cached --check
git diff --cached --name-only
git commit -m "feat(flutter): integrate DRF projects auth and CI pipeline"
git push origin main
```

**Status akhir: BLOCKED untuk pengumpulan.** Suite Django dan Flutter, CORS
melalui test client, dan build web lulus. HTTP live, browser E2E, dan APK
masih belum terverifikasi. GitHub Actions menunggu push manual dan run nyata.
