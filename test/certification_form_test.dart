import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/certification_form.dart';
import 'package:myportofolio_mobile/screens/certification_list_screen.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

const _successTitle = 'Sertifikasi berhasil ditambahkan!';
const _expirationLabel = 'Tanggal Kedaluwarsa (opsional)';

typedef _RecordedCertRequest = ({
  String method,
  String path,
  Map<String, String> headers,
  String body,
});

class _MockBackend {
  final List<_RecordedCertRequest> posts = [];
  final List<_RecordedCertRequest> gets = [];
  final List<Map<String, dynamic>> serverRows = [];
  final List<FutureOr<http.Response> Function(Map<String, dynamic>)>
  postHandlers = [];
  int loginCount = 0;
  int _nextId = 1;

  ApiClient buildClient() {
    return ApiClient(
      client: MockClient((request) async {
        final headers = request.headers.map(
          (k, v) => MapEntry(k.toLowerCase(), v),
        );
        if (request.url.path.endsWith('/auth/token/')) {
          loginCount += 1;
          return http.Response('{"token":"token-$loginCount"}', 200);
        }
        if (request.url.path.endsWith('/auth/logout/')) {
          return http.Response('', 204);
        }
        if (request.method == 'GET' &&
            request.url.path == '/api/v1/certifications/') {
          gets.add((
            method: request.method,
            path: request.url.path,
            headers: headers,
            body: request.body,
          ));
          return http.Response.bytes(utf8.encode(jsonEncode(serverRows)), 200);
        }
        if (request.method == 'POST' &&
            request.url.path == '/api/v1/certifications/') {
          posts.add((
            method: request.method,
            path: request.url.path,
            headers: headers,
            body: request.body,
          ));
          final decoded = jsonDecode(request.body) as Map<String, dynamic>;
          if (postHandlers.isNotEmpty) {
            return await postHandlers.removeAt(0)(decoded);
          }
          final created = <String, dynamic>{
            'id': _nextId++,
            ...decoded,
            'star_count': 0,
            'is_starred': false,
            'starred_by_names': '',
          };
          serverRows.add(created);
          return http.Response.bytes(utf8.encode(jsonEncode(created)), 201);
        }
        return http.Response('[]', 200);
      }),
    );
  }
}

Future<_MockBackend> _pumpApp(
  WidgetTester tester, {
  List<FutureOr<http.Response> Function(Map<String, dynamic>)>? postHandlers,
}) async {
  final backend = _MockBackend();
  if (postHandlers != null) {
    backend.postHandlers.addAll(postHandlers);
  }
  final api = backend.buildClient();
  addTearDown(api.close);
  await tester.pumpWidget(MyApp(apiClient: api));
  await tester.pumpAndSettle();
  return backend;
}

Future<void> _completeLogin(WidgetTester tester) async {
  expect(find.byType(LoginScreen), findsOneWidget);
  await tester.enterText(find.byType(TextFormField).at(0), 'qa-user');
  await tester.enterText(find.byType(TextFormField).at(1), 'qa-password');
  final submit = find.text('Masuk');
  await tester.ensureVisible(submit);
  await tester.tap(submit);
  await tester.pumpAndSettle();
}

Future<void> _openForm(WidgetTester tester) async {
  await _tapVisible(tester, find.text('Tambah Sertifikasi'));
  if (find.byType(LoginScreen).evaluate().isNotEmpty) {
    await _completeLogin(tester);
  }
  expect(find.byType(CertificationFormPage), findsOneWidget);
}

Future<void> _enterText(WidgetTester tester, String label, String value) async {
  final field = find.ancestor(
    of: find.text(label),
    matching: find.byType(TextFormField),
  );
  await tester.ensureVisible(field);
  await tester.enterText(field, value);
  await tester.pumpAndSettle();
}

Future<void> _fillText(WidgetTester tester) async {
  await _enterText(tester, 'Nama Sertifikasi', '  Flutter Associate  ');
  await _enterText(tester, 'Lembaga Penerbit', 'Flutter Academy');
  await _enterText(tester, 'ID Kredensial', 'FL-123');
  await _enterText(
    tester,
    'URL Kredensial',
    'https://example.com/verify/FL-123',
  );
}

Future<void> _tapVisible(WidgetTester tester, Finder target) async {
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target.hitTestable());
  await tester.pumpAndSettle();
}

Future<void> _pickDate(WidgetTester tester, String label, DateTime date) async {
  final button = find.ancestor(
    of: find.text(label),
    matching: find.byType(OutlinedButton),
  );
  await _tapVisible(tester, button);
  final dialog = find.byType(DatePickerDialog);
  final localizations = MaterialLocalizations.of(tester.element(dialog));
  await tester.tap(find.byTooltip(localizations.inputDateModeButtonLabel));
  await tester.pumpAndSettle();
  await tester.enterText(
    find.descendant(of: dialog, matching: find.byType(TextFormField)),
    localizations.formatCompactDate(date),
  );
  await tester.tap(
    find.descendant(
      of: dialog,
      matching: find.text(localizations.okButtonLabel),
    ),
  );
  await tester.pumpAndSettle();
  expect(dialog, findsNothing);
}

Future<void> _dismissNavSnackBar(WidgetTester tester) async {
  final snackBar = find.ancestor(
    of: find.text('Kamu telah menekan tombol Tambah Sertifikasi!'),
    matching: find.byType(SnackBar),
  );
  if (snackBar.evaluate().isNotEmpty) {
    await tester.pump(tester.widget<SnackBar>(snackBar).duration);
    await tester.pumpAndSettle();
    expect(snackBar, findsNothing);
  }
}

Future<void> _save(WidgetTester tester) async {
  await _dismissNavSnackBar(tester);
  final button = find.byType(FilledButton);
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  expect(button.hitTestable(), findsOneWidget);
  expect(tester.widget<FilledButton>(button).onPressed, isNotNull);
  await tester.tap(button.hitTestable());
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('input wajib kosong atau whitespace ditolak tanpa POST', (
    tester,
  ) async {
    final backend = await _pumpApp(tester);
    await _openForm(tester);
    await _enterText(tester, 'Nama Sertifikasi', '   ');
    await _enterText(tester, 'ID Kredensial', '   ');
    await _save(tester);

    for (final field in [
      'Nama Sertifikasi',
      'Lembaga Penerbit',
      'ID Kredensial',
      'URL Kredensial',
      'Tanggal Terbit',
    ]) {
      expect(find.text('$field wajib diisi.'), findsOneWidget);
    }
    expect(find.text(_successTitle), findsNothing);
    expect(backend.posts, isEmpty);
  });

  testWidgets('batas panjang teks dan URL diterapkan tanpa POST', (
    tester,
  ) async {
    final backend = await _pumpApp(tester);
    await _openForm(tester);
    for (final field in [
      'Nama Sertifikasi',
      'Lembaga Penerbit',
      'ID Kredensial',
    ]) {
      await _enterText(tester, field, 'a' * 256);
    }
    await _enterText(
      tester,
      'URL Kredensial',
      'https://example.com/${'a' * 181}',
    );
    await _save(tester);

    for (final field in [
      'Nama Sertifikasi',
      'Lembaga Penerbit',
      'ID Kredensial',
    ]) {
      expect(find.text('$field maksimal 255 karakter.'), findsOneWidget);
    }
    expect(find.text('URL Kredensial maksimal 200 karakter.'), findsOneWidget);
    expect(find.text(_successTitle), findsNothing);
    expect(backend.posts, isEmpty);
  });

  testWidgets(
    'URL tanpa host, skema lain, dan spasi internal ditolak tanpa POST',
    (tester) async {
      final backend = await _pumpApp(tester);
      await _openForm(tester);
      await _fillText(tester);
      await _pickDate(tester, 'Tanggal Terbit', DateTime(2026, 11, 20));

      for (final url in [
        'https:///verify',
        'javascript:alert(1)',
        'https://example.com/a b',
      ]) {
        await _enterText(tester, 'URL Kredensial', url);
        await _save(tester);
        expect(
          find.text('Masukkan URL HTTP atau HTTPS yang valid.'),
          findsOneWidget,
        );
        expect(find.text(_successTitle), findsNothing);
      }
      expect(backend.posts, isEmpty);
    },
  );

  testWidgets(
    'urutan tanggal diperiksa ulang lalu POST 201 saat tanggal sama',
    (tester) async {
      final backend = await _pumpApp(tester);
      await _openForm(tester);
      await _fillText(tester);
      await _pickDate(tester, 'Tanggal Terbit', DateTime(2026, 11, 20));
      await _pickDate(tester, _expirationLabel, DateTime(2026, 11, 19));
      await _save(tester);
      expect(
        find.text('Tanggal kedaluwarsa tidak boleh sebelum tanggal terbit.'),
        findsOneWidget,
      );
      expect(find.text(_successTitle), findsNothing);
      expect(backend.posts, isEmpty);

      await _pickDate(tester, 'Tanggal Terbit', DateTime(2026, 11, 19));
      await _save(tester);
      expect(backend.posts, hasLength(1));
      expect(find.text(_successTitle), findsOneWidget);
      expect(find.text('Tanggal Terbit: 2026-11-19'), findsOneWidget);
      expect(find.text('Tanggal Kedaluwarsa: 2026-11-19'), findsOneWidget);
    },
  );

  testWidgets(
    'POST 201 mengirim JSON bertoken tanpa id, tampilkan data server, dan reset form',
    (tester) async {
      final backend = await _pumpApp(
        tester,
        postHandlers: [
          (body) => http.Response(
            jsonEncode({
              'id': 88,
              ...body,
              'name': 'Flutter Associate (Server)',
            }),
            201,
          ),
        ],
      );
      await _openForm(tester);
      await _fillText(tester);
      await _pickDate(tester, 'Tanggal Terbit', DateTime(2026, 11, 20));
      await _pickDate(tester, _expirationLabel, DateTime(2027, 11, 20));
      await _save(tester);

      expect(backend.posts, hasLength(1));
      final post = backend.posts.single;
      expect(post.method, 'POST');
      expect(post.path, '/api/v1/certifications/');
      expect(post.headers['authorization'], 'Token token-1');
      final decoded = jsonDecode(post.body) as Map<String, dynamic>;
      expect(decoded, isNot(contains('id')));
      expect(decoded, <String, dynamic>{
        'name': 'Flutter Associate',
        'issuing_organization': 'Flutter Academy',
        'issue_date': '2026-11-20',
        'expiration_date': '2027-11-20',
        'credential_id': 'FL-123',
        'credential_url': 'https://example.com/verify/FL-123',
      });

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text(_successTitle), findsOneWidget);
      for (final line in [
        'Nama Sertifikasi: Flutter Associate (Server)',
        'Lembaga Penerbit: Flutter Academy',
        'ID Kredensial: FL-123',
        'URL Kredensial: https://example.com/verify/FL-123',
        'Tanggal Terbit: 2026-11-20',
        'Tanggal Kedaluwarsa: 2027-11-20',
      ]) {
        expect(find.text(line), findsOneWidget);
      }

      await tester.tap(find.text('Tutup'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(CertificationFormPage), findsOneWidget);
      expect(find.text('  Flutter Associate  '), findsNothing);
      expect(find.text('Nov 20, 2027'), findsNothing);

      await _save(tester);
      expect(backend.posts, hasLength(1));
      expect(find.text('Nama Sertifikasi wajib diisi.'), findsOneWidget);
    },
  );

  testWidgets('tanggal kedaluwarsa opsional mengirim null saat dikosongkan', (
    tester,
  ) async {
    final backend = await _pumpApp(tester);
    await _openForm(tester);
    await _fillText(tester);
    await _pickDate(tester, 'Tanggal Terbit', DateTime(2026, 11, 20));
    await _pickDate(tester, _expirationLabel, DateTime(2027, 11, 20));
    await _tapVisible(tester, find.byTooltip('Hapus tanggal kedaluwarsa'));
    await _save(tester);

    expect(backend.posts, hasLength(1));
    final decoded =
        jsonDecode(backend.posts.single.body) as Map<String, dynamic>;
    expect(decoded['expiration_date'], isNull);
    expect(find.text('Tanggal Kedaluwarsa: Tidak diisi'), findsOneWidget);
  });

  testWidgets('navigasi terproteksi dan batal login menahan akses form', (
    tester,
  ) async {
    final backend = await _pumpApp(tester);

    await _tapVisible(tester, find.text('Tambah Sertifikasi'));
    expect(find.byType(LoginScreen), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(MyHomePage), findsOneWidget);
    expect(find.byType(CertificationFormPage), findsNothing);

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Certification'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(MyHomePage), findsOneWidget);
    expect(find.byType(CertificationFormPage), findsNothing);

    await _tapVisible(tester, find.text('Lihat Sertifikasi'));
    expect(find.byType(CertificationListScreen), findsOneWidget);
    await tester.tap(find.byTooltip('Tambah Sertifikasi'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(CertificationListScreen), findsOneWidget);
    expect(find.byType(CertificationFormPage), findsNothing);
    expect(backend.posts, isEmpty);
  });

  testWidgets(
    'POST 201 lalu Lihat Daftar memperbarui daftar sertifikasi dari Home dan List',
    (tester) async {
      final backend = await _pumpApp(tester);
      await _openForm(tester);
      await _fillText(tester);
      await _pickDate(tester, 'Tanggal Terbit', DateTime(2026, 11, 20));
      await _save(tester);

      await tester.tap(find.text('Lihat Daftar'));
      await tester.pumpAndSettle();
      expect(find.byType(CertificationListScreen), findsOneWidget);
      expect(find.text('Flutter Associate'), findsOneWidget);
      expect(backend.gets, hasLength(1));

      await tester.tap(find.byTooltip('Tambah Sertifikasi'));
      await tester.pumpAndSettle();
      expect(find.byType(CertificationFormPage), findsOneWidget);
      await _enterText(tester, 'Nama Sertifikasi', 'Second Cert');
      await _enterText(tester, 'Lembaga Penerbit', 'Second Org');
      await _enterText(tester, 'ID Kredensial', 'SEC-2');
      await _enterText(
        tester,
        'URL Kredensial',
        'https://example.com/verify/SEC-2',
      );
      await _pickDate(tester, 'Tanggal Terbit', DateTime(2026, 11, 21));
      await _save(tester);

      await tester.tap(find.text('Lihat Daftar'));
      await tester.pumpAndSettle();
      expect(find.byType(CertificationListScreen), findsOneWidget);
      expect(find.text('Flutter Associate'), findsOneWidget);
      expect(find.text('Second Cert'), findsOneWidget);
      expect(backend.gets, hasLength(2));
    },
  );

  testWidgets(
    'POST 401 menghapus sesi, meminta login ulang, menjaga isian, dan tidak auto-replay',
    (tester) async {
      final backend = await _pumpApp(
        tester,
        postHandlers: [(_) => http.Response('{}', 401)],
      );
      await _openForm(tester);
      await _fillText(tester);
      await _pickDate(tester, 'Tanggal Terbit', DateTime(2026, 11, 20));
      await _pickDate(tester, _expirationLabel, DateTime(2027, 11, 20));
      await _save(tester);

      expect(backend.posts, hasLength(1));
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(
        find.text('Sesi tidak valid. Silakan masuk lagi.'),
        findsOneWidget,
      );

      final auth = tester.element(find.byType(LoginScreen)).read<AuthState>();
      expect(auth.isLoggedIn, isFalse);
      expect(auth.token, isNull);

      await _completeLogin(tester);
      expect(find.byType(CertificationFormPage), findsOneWidget);
      expect(auth.isLoggedIn, isTrue);
      expect(auth.token, 'token-2');
      // Tidak auto-replay setelah re-login.
      expect(backend.posts, hasLength(1));

      expect(find.text('  Flutter Associate  '), findsOneWidget);
      expect(find.text('Flutter Academy'), findsOneWidget);
      expect(find.text('FL-123'), findsOneWidget);
      expect(find.text('https://example.com/verify/FL-123'), findsOneWidget);
      expect(find.text('Nov 20, 2026'), findsOneWidget);
      expect(find.text('Nov 20, 2027'), findsOneWidget);

      await _save(tester);
      expect(backend.posts, hasLength(2));
      expect(backend.posts[1].headers['authorization'], 'Token token-2');
      expect(find.text(_successTitle), findsOneWidget);
    },
  );

  testWidgets('POST 403 menjaga sesi dan isian tanpa login ulang', (
    tester,
  ) async {
    final backend = await _pumpApp(
      tester,
      postHandlers: [(_) => http.Response('{}', 403)],
    );
    await _openForm(tester);
    await _fillText(tester);
    await _pickDate(tester, 'Tanggal Terbit', DateTime(2026, 11, 20));
    await _save(tester);

    expect(backend.posts, hasLength(1));
    expect(find.byType(LoginScreen), findsNothing);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(CertificationFormPage), findsOneWidget);
    expect(
      find.text('Akun ini tidak memiliki izin untuk tindakan tersebut.'),
      findsOneWidget,
    );
    expect(find.text('  Flutter Associate  '), findsOneWidget);

    final auth = tester
        .element(find.byType(CertificationFormPage))
        .read<AuthState>();
    expect(auth.isLoggedIn, isTrue);
    expect(auth.token, 'token-1');
  });

  testWidgets(
    'POST 400 dan gangguan jaringan menjaga isian serta menampilkan SnackBar',
    (tester) async {
      final backend = await _pumpApp(
        tester,
        postHandlers: [
          (_) => http.Response('{"name":["Invalid"]}', 400),
          (_) => throw http.ClientException('offline'),
        ],
      );
      await _openForm(tester);
      await _fillText(tester);
      await _pickDate(tester, 'Tanggal Terbit', DateTime(2026, 11, 20));
      await _save(tester);

      expect(backend.posts, hasLength(1));
      expect(find.byType(AlertDialog), findsNothing);
      expect(
        find.text('Data ditolak oleh server. Periksa isian Anda.'),
        findsOneWidget,
      );
      expect(find.text('  Flutter Associate  '), findsOneWidget);

      await _save(tester);
      expect(backend.posts, hasLength(2));
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Tidak dapat terhubung ke server.'), findsOneWidget);
      expect(find.text('  Flutter Associate  '), findsOneWidget);
    },
  );

  testWidgets(
    'batal re-login setelah 401 menjaga sesi keluar, mempertahankan isian, dan tanpa auto-replay',
    (tester) async {
      final backend = await _pumpApp(
        tester,
        postHandlers: [(_) => http.Response('{}', 401)],
      );
      await _openForm(tester);
      await _fillText(tester);
      await _pickDate(tester, 'Tanggal Terbit', DateTime(2026, 11, 20));
      await _pickDate(tester, _expirationLabel, DateTime(2027, 11, 20));
      await _save(tester);

      expect(backend.posts, hasLength(1));
      expect(find.byType(LoginScreen), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.byType(CertificationFormPage), findsOneWidget);
      expect(backend.posts, hasLength(1));
      final auth = tester
          .element(find.byType(CertificationFormPage))
          .read<AuthState>();
      expect(auth.isLoggedIn, isFalse);
      expect(auth.token, isNull);
      expect(find.text('  Flutter Associate  '), findsOneWidget);
      expect(find.text('Nov 20, 2027'), findsOneWidget);

      // Re-saving prompts Login again, then explicit Save succeeds cleanly.
      await _save(tester);
      expect(find.byType(LoginScreen), findsOneWidget);
      await _completeLogin(tester);
      expect(backend.posts, hasLength(2));
      expect(backend.posts[1].headers['authorization'], 'Token token-2');
      expect(find.text(_successTitle), findsOneWidget);
    },
  );

  testWidgets(
    'Tutup setelah 201 dari List lalu Back memicu refresh daftar sertifikasi',
    (tester) async {
      final backend = await _pumpApp(tester);
      await _tapVisible(tester, find.text('Lihat Sertifikasi'));
      expect(find.byType(CertificationListScreen), findsOneWidget);
      expect(backend.gets, hasLength(1));

      await tester.tap(find.byTooltip('Tambah Sertifikasi'));
      await tester.pumpAndSettle();
      await _completeLogin(tester);

      await _fillText(tester);
      await _pickDate(tester, 'Tanggal Terbit', DateTime(2026, 11, 20));
      await _save(tester);
      expect(find.text(_successTitle), findsOneWidget);

      await tester.tap(find.text('Tutup'));
      await tester.pumpAndSettle();
      expect(find.byType(CertificationFormPage), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(CertificationListScreen), findsOneWidget);
      expect(backend.gets, hasLength(2));
      expect(find.text('Flutter Associate'), findsOneWidget);
    },
  );

  testWidgets(
    'skala teks 200% dan karakter Unicode panjang tampil tanpa overflow',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      final backend = _MockBackend();
      final api = backend.buildClient();
      addTearDown(api.close);
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
          child: MyApp(apiClient: api),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await _openForm(tester);
      await _enterText(
        tester,
        'Nama Sertifikasi',
        'Sertifikasi Keamanan Şebnem Çağrı Café',
      );
      await _enterText(tester, 'Lembaga Penerbit', 'İstanbul Teknik Enstitüsü');
      await _enterText(tester, 'ID Kredensial', 'TR-İĞŞ-2026');
      await _enterText(
        tester,
        'URL Kredensial',
        'https://example.com/verify/unicode-cert-2026',
      );
      await _pickDate(tester, 'Tanggal Terbit', DateTime(2026, 11, 20));
      await _save(tester);

      expect(find.text(_successTitle), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'mencegah pengiriman ganda dan menonaktifkan drawer saat POST masih diproses',
    (tester) async {
      final pendingPost = Completer<http.Response>();
      final backend = await _pumpApp(
        tester,
        postHandlers: [(_) => pendingPost.future],
      );
      await _openForm(tester);
      await _fillText(tester);
      await _pickDate(tester, 'Tanggal Terbit', DateTime(2026, 11, 20));

      await _dismissNavSnackBar(tester);
      final button = find.byType(FilledButton);
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await tester.tap(button.hitTestable());
      await tester.pump();

      expect(find.text('Menyimpan…'), findsOneWidget);
      expect(tester.widget<FilledButton>(button).onPressed, isNull);
      expect(
        tester.widget<Scaffold>(find.byType(Scaffold).last).drawer,
        isNull,
      );
      await tester.tap(button.hitTestable());
      await tester.pump();
      expect(backend.posts, hasLength(1));

      pendingPost.complete(
        http.Response(
          jsonEncode({
            'id': 55,
            'name': 'Flutter Associate',
            'issuing_organization': 'Flutter Academy',
            'issue_date': '2026-11-20',
            'expiration_date': null,
            'credential_id': 'FL-123',
            'credential_url': 'https://example.com/verify/FL-123',
          }),
          201,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(_successTitle), findsOneWidget);
    },
  );

  for (final size in const [
    Size(320, 640),
    Size(390, 844),
    Size(768, 1024),
    Size(1280, 800),
  ]) {
    testWidgets(
      'Simpan terjangkau pada ${size.width.toInt()}×${size.height.toInt()}',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        final backend = await _pumpApp(tester);
        await _openForm(tester);

        if (size.width == 320) {
          await _dismissNavSnackBar(tester);
          await _enterText(tester, 'Nama Sertifikasi', 'Flutter Associate');
          tester.view.viewInsets = const FakeViewPadding(bottom: 280);
          addTearDown(tester.view.resetViewInsets);
          await tester.pumpAndSettle();

          final saveButton = find.text('Simpan').hitTestable();
          await tester.dragUntilVisible(
            saveButton,
            find.byType(SingleChildScrollView),
            const Offset(0, -180),
          );
          await tester.tap(saveButton);
          await tester.pumpAndSettle();
        } else {
          await _save(tester);
        }
        expect(find.text('Tanggal Terbit wajib diisi.'), findsOneWidget);
        expect(backend.posts, isEmpty);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
