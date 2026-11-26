import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/models/certification.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';

const _certPayload = <String, dynamic>{
  'id': 7,
  'name': 'Arsitek Cloud Café',
  'issuing_organization': 'Cloud Institute',
  'issue_date': '2026-06-01',
  'expiration_date': null,
  'credential_id': 'CERT-007',
  'credential_url': 'https://example.com/verify/CERT-007',
  'star_count': 2,
  'is_starred': false,
  'starred_by_names': '',
};

void main() {
  test(
    'getCertifications publik dan createCertification token UTF-8',
    () async {
      final recorded =
          <
            ({
              String method,
              String url,
              Map<String, String> headers,
              String body,
            })
          >[];

      final api = ApiClient(
        baseUrl: 'http://localhost:8000',
        client: MockClient((request) async {
          recorded.add((
            method: request.method,
            url: request.url.toString(),
            headers: request.headers.map(
              (k, v) => MapEntry(k.toLowerCase(), v),
            ),
            body: request.body,
          ));
          if (request.method == 'GET') {
            return http.Response.bytes(
              utf8.encode(
                jsonEncode([
                  _certPayload,
                  {
                    ..._certPayload,
                    'id': 8,
                    'name': 'Security Specialist',
                    'expiration_date': '2029-06-01',
                  },
                ]),
              ),
              200,
            );
          }
          return http.Response.bytes(
            utf8.encode(jsonEncode(_certPayload)),
            201,
          );
        }),
      );
      addTearDown(api.close);

      final list = await api.getCertifications();
      expect(list, hasLength(2));
      expect(list[0].id, 7);
      expect(list[0].name, 'Arsitek Cloud Café');
      expect(list[0].expirationDate, isNull);
      expect(list[1].expirationDate, '2029-06-01');

      final created = await api.createCertification(
        const Certification(
          id: 999,
          name: 'Arsitek Cloud Café',
          issuingOrganization: 'Cloud Institute',
          issueDate: '2026-06-01',
          credentialId: 'CERT-007',
          credentialUrl: 'https://example.com/verify/CERT-007',
        ),
        token: 'test-token',
      );
      expect(created.id, 7);
      expect(created.name, 'Arsitek Cloud Café');

      expect(recorded, hasLength(2));
      final getReq = recorded[0];
      expect(getReq.method, 'GET');
      expect(getReq.url, 'http://localhost:8000/api/v1/certifications/');
      expect(getReq.headers['accept'], 'application/json');
      expect(getReq.headers, isNot(contains('authorization')));

      final postReq = recorded[1];
      expect(postReq.method, 'POST');
      expect(postReq.url, 'http://localhost:8000/api/v1/certifications/');
      expect(postReq.headers['accept'], 'application/json');
      expect(postReq.headers['authorization'], 'Token test-token');
      expect(postReq.headers['content-type'], startsWith('application/json'));
      final decodedBody = jsonDecode(postReq.body) as Map<String, dynamic>;
      expect(decodedBody, isNot(contains('id')));
      expect(decodedBody, <String, dynamic>{
        'name': 'Arsitek Cloud Café',
        'issuing_organization': 'Cloud Institute',
        'issue_date': '2026-06-01',
        'expiration_date': null,
        'credential_id': 'CERT-007',
        'credential_url': 'https://example.com/verify/CERT-007',
      });
    },
  );

  test(
    'getCertifications menangani array kosong dan error HTTP/JSON/jaringan',
    () async {
      final responses = [
        http.Response('[]', 200),
        http.Response('{}', 400),
        http.Response('{}', 401),
        http.Response('{}', 403),
        http.Response('<html>error</html>', 502),
        http.Response('{}', 200),
        http.Response('not-json', 200),
      ];
      final api = ApiClient(
        client: MockClient((_) async {
          if (responses.isEmpty) throw http.ClientException('offline');
          return responses.removeAt(0);
        }),
      );
      addTearDown(api.close);

      expect(await api.getCertifications(), isEmpty);

      for (final expectedCode in [400, 401, 403, 502]) {
        await expectLater(
          api.getCertifications(),
          throwsA(
            isA<ApiException>().having(
              (e) => e.statusCode,
              'statusCode',
              expectedCode,
            ),
          ),
        );
      }

      for (var i = 0; i < 3; i++) {
        await expectLater(
          api.getCertifications(),
          throwsA(isA<ApiException>()),
        );
      }
    },
  );

  test('AuthState.invalidate mengabaikan token usang dan logout paralel hanya kirim satu POST', () async {
    var loginSeq = 0;
    var logoutRequests = 0;
    final logoutGate = Completer<http.Response>();
    final api = ApiClient(
      client: MockClient((request) async {
        if (request.url.path.endsWith('/auth/token/')) {
          loginSeq += 1;
          return http.Response('{"token":"tok-$loginSeq"}', 200);
        }
        if (request.url.path.endsWith('/auth/logout/')) {
          logoutRequests += 1;
          return logoutGate.future;
        }
        return http.Response('{}', 404);
      }),
    );
    final auth = AuthState(api);
    var notifications = 0;
    auth.addListener(() => notifications += 1);
    addTearDown(auth.dispose);
    addTearDown(api.close);

    await auth.login('qa-user', 'qa-pass');
    expect(auth.token, 'tok-1');
    expect(notifications, 1);

    auth.invalidate('stale-tok-0');
    expect(auth.token, 'tok-1');
    expect(auth.isLoggedIn, isTrue);
    expect(notifications, 1);

    auth.invalidate('tok-1');
    expect(auth.token, isNull);
    expect(auth.isLoggedIn, isFalse);
    expect(notifications, 2);

    await auth.login('qa-user', 'qa-pass');
    expect(auth.token, 'tok-2');

    final firstLogout = auth.logout();
    final secondLogout = auth.logout();
    await Future<void>.delayed(Duration.zero);
    expect(logoutRequests, 1);
    logoutGate.complete(http.Response('', 204));
    await Future.wait([firstLogout, secondLogout]);

    expect(logoutRequests, 1);
    expect(auth.token, isNull);
    expect(auth.isLoggedIn, isFalse);
  });
}
