import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';

const _projectBody = <String, dynamic>{
  'id': '30fd83fd-4be5-4492-a4ef-fe2dc096ceaa',
  'title': 'Proyek Café',
  'description': 'Deskripsi proyek.',
  'tech_stack': 'Flutter',
  'project_url': 'https://example.com',
  'star_count': 0,
};

void main() {
  test('Project membaca snake_case dan mengabaikan ID ketika POST', () {
    for (final body in [
      _projectBody,
      {..._projectBody, 'project_image_url': null},
    ]) {
      final project = Project.fromJson(body);
      expect(project.id, _projectBody['id']);
      expect(project.projectImageUrl, isEmpty);
      expect(project.toJson(), {
        'title': _projectBody['title'],
        'description': _projectBody['description'],
        'tech_stack': 'Flutter',
        'project_url': 'https://example.com',
        'project_image_url': '',
      });
    }
  });

  test('GET publik dan POST token memakai kontrak Django dan UTF-8', () async {
    final api = ApiClient(
      baseUrl: 'http://localhost:8000',
      client: MockClient((request) async {
        expect(
          request.url.toString(),
          'http://localhost:8000/api/v1/projects/',
        );
        expect(request.headers['accept'], 'application/json');
        if (request.method == 'GET') {
          expect(request.headers, isNot(contains('authorization')));
          return http.Response.bytes(
            utf8.encode(jsonEncode([_projectBody])),
            200,
          );
        }
        expect(request.method, 'POST');
        expect(request.headers['authorization'], 'Token test-token');
        expect(request.headers['content-type'], startsWith('application/json'));
        expect(jsonDecode(request.body), isNot(contains('id')));
        return http.Response.bytes(utf8.encode(jsonEncode(_projectBody)), 201);
      }),
    );
    addTearDown(api.close);
    final list = await api.getProjects();
    expect(list.single.title, 'Proyek Café');
    expect(
      (await api.createProject(list.single, token: 'test-token')).id,
      list.single.id,
    );
  });

  test(
    'respons salah dan kegagalan jaringan menghasilkan ApiException',
    () async {
      final responses = [
        http.Response('[]', 200),
        http.Response('<html>', 502),
        http.Response('{}', 200),
        http.Response('garbage', 200),
      ];
      final api = ApiClient(
        client: MockClient((_) async {
          if (responses.isEmpty) throw http.ClientException('offline');
          return responses.removeAt(0);
        }),
      );
      addTearDown(api.close);
      expect(await api.getProjects(), isEmpty);
      await expectLater(
        api.getProjects(),
        throwsA(
          isA<ApiException>().having(
            (error) => error.statusCode,
            'status',
            502,
          ),
        ),
      );
      for (var i = 0; i < 3; i++) {
        await expectLater(api.getProjects(), throwsA(isA<ApiException>()));
      }
    },
  );

  test(
    'login mengubah state dan kegagalan logout tetap menghapus token',
    () async {
      var logoutStatus = 503;
      final api = ApiClient(
        client: MockClient((request) async {
          if (request.url.path.endsWith('/auth/token/')) {
            final body = jsonDecode(request.body) as Map<String, dynamic>;
            return body['username'] == 'user'
                ? http.Response('{"token":"test-token"}', 200)
                : http.Response('{}', 400);
          }
          expect(request.method, 'POST');
          expect(request.url.path, '/api/v1/auth/logout/');
          expect(request.headers['authorization'], 'Token test-token');
          return http.Response('', logoutStatus);
        }),
      );
      final auth = AuthState(api);
      addTearDown(auth.dispose);
      addTearDown(api.close);
      await expectLater(
        auth.login('unknown', 'test-password'),
        throwsA(isA<ApiException>()),
      );
      expect(auth.isLoggedIn, isFalse);
      await auth.login('user', 'test-password');
      expect(auth.isLoggedIn, isTrue);
      await expectLater(auth.logout(), throwsA(isA<ApiException>()));
      expect(auth.token, isNull);
      logoutStatus = 204;
      await auth.login('user', 'test-password');
      await auth.logout();
      expect(auth.isLoggedIn, isFalse);
    },
  );
}
