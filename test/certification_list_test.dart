import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/certification_detail_screen.dart';
import 'package:myportofolio_mobile/screens/certification_list_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

void main() {
  testWidgets(
    'GET publik sekali, loading, retry, empty refresh, dan detail sertifikasi',
    (tester) async {
      final initialResponse = Completer<http.Response>();
      final requests =
          <({String method, String path, Map<String, String> headers})>[];
      final api = ApiClient(
        client: MockClient((request) async {
          requests.add((
            method: request.method,
            path: request.url.path,
            headers: request.headers.map(
              (k, v) => MapEntry(k.toLowerCase(), v),
            ),
          ));
          switch (requests.length) {
            case 1:
              return initialResponse.future;
            case 2:
              return http.Response('[]', 200);
            default:
              return http.Response(
                jsonEncode([
                  {
                    'id': 1,
                    'name': 'Cloud Architect',
                    'issuing_organization': 'Cloud Org',
                    'issue_date': '2026-01-15',
                    'expiration_date': '2029-01-15',
                    'credential_id': 'CERT-101',
                    'credential_url': 'https://example.com/verify/CERT-101',
                  },
                  {
                    'id': 2,
                    'name': 'Lifetime Security',
                    'issuing_organization': 'Sec Guild',
                    'issue_date': '2026-03-20',
                    'expiration_date': null,
                    'credential_id': 'CERT-202',
                    'credential_url': 'https://example.com/verify/CERT-202',
                  },
                ]),
                200,
              );
          }
        }),
      );
      addTearDown(api.close);

      await tester.pumpWidget(MyApp(apiClient: api));
      final card = find.text('Lihat Sertifikasi');
      await tester.ensureVisible(card);
      await tester.tap(card);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(CertificationListScreen), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(requests, hasLength(1));

      initialResponse.complete(http.Response('{}', 503));
      await tester.pumpAndSettle();
      expect(find.text('Coba lagi'), findsOneWidget);

      await tester.tap(find.text('Coba lagi'));
      await tester.pumpAndSettle();
      expect(find.text('Belum ada sertifikasi.'), findsOneWidget);
      expect(requests, hasLength(2));

      await tester.drag(find.byType(ListView), const Offset(0, 400));
      await tester.pumpAndSettle();
      expect(requests, hasLength(3));
      expect(find.text('Cloud Architect'), findsOneWidget);
      expect(find.text('Lifetime Security'), findsOneWidget);

      await tester.tap(find.text('Cloud Architect'));
      await tester.pumpAndSettle();
      expect(find.byType(CertificationDetailScreen), findsOneWidget);
      expect(find.text('Lembaga Penerbit: Cloud Org'), findsOneWidget);
      expect(find.text('ID Kredensial: CERT-101'), findsOneWidget);
      expect(find.text('Tanggal Terbit: 2026-01-15'), findsOneWidget);
      expect(find.text('Tanggal Kedaluwarsa: 2029-01-15'), findsOneWidget);
      expect(
        find.text('URL Kredensial: https://example.com/verify/CERT-101'),
        findsOneWidget,
      );

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(requests, hasLength(3));

      await tester.tap(find.text('Lifetime Security'));
      await tester.pumpAndSettle();
      expect(
        find.text('Tanggal Kedaluwarsa: Tidak kedaluwarsa'),
        findsOneWidget,
      );

      for (final request in requests) {
        expect(request.method, 'GET');
        expect(request.path, '/api/v1/certifications/');
        expect(request.headers, isNot(contains('authorization')));
      }
    },
  );

  testWidgets(
    'drawer View Certifications membuka daftar dan tidak memuat ulang saat sudah aktif',
    (tester) async {
      final requests = <String>[];
      final api = ApiClient(
        client: MockClient((request) async {
          requests.add('${request.method} ${request.url.path}');
          return http.Response('[]', 200);
        }),
      );
      addTearDown(api.close);

      await tester.pumpWidget(MyApp(apiClient: api));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('View Certifications'));
      await tester.pumpAndSettle();

      expect(find.byType(CertificationListScreen), findsOneWidget);
      expect(requests, ['GET /api/v1/certifications/']);

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('View Certifications'));
      await tester.pumpAndSettle();

      expect(find.byType(CertificationListScreen), findsOneWidget);
      expect(requests, ['GET /api/v1/certifications/']);
    },
  );

  testWidgets(
    'daftar dan detail sertifikasi dengan teks/URL panjang aman pada 320x640',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const longName =
          'Sertifikasi Keamanan Sistem Terdistribusi dan Infrastruktur Cloud Enterprise';
      const longUrl =
          'https://verify.example.com/certificates/organization/department/2026/very-long-credential-identifier-001';
      final api = ApiClient(
        client: MockClient(
          (_) async => http.Response(
            jsonEncode([
              {
                'id': 11,
                'name': longName,
                'issuing_organization': 'Lembaga Sertifikasi Nasional',
                'issue_date': '2026-10-01',
                'expiration_date': null,
                'credential_id': 'LONG-CRED-2026-001',
                'credential_url': longUrl,
              },
            ]),
            200,
          ),
        ),
      );
      addTearDown(api.close);

      await tester.pumpWidget(MyApp(apiClient: api));
      await tester.pumpAndSettle();

      final card = find.text('Lihat Sertifikasi');
      await tester.ensureVisible(card);
      await tester.pumpAndSettle();
      await tester.tap(card.hitTestable());
      await tester.pumpAndSettle();

      expect(find.byType(CertificationListScreen), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text(longName));
      await tester.pumpAndSettle();

      expect(find.byType(CertificationDetailScreen), findsOneWidget);
      expect(find.text('URL Kredensial: $longUrl'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
