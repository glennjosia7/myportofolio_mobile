import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/project_detail_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

void main() {
  testWidgets('GET sekali, retry, refresh, dan detail proyek publik', (
    tester,
  ) async {
    final initialResponse = Completer<http.Response>();
    final requests = <http.Request>[];
    final api = ApiClient(
      client: MockClient((request) async {
        requests.add(request);
        switch (requests.length) {
          case 1:
            return initialResponse.future;
          case 2:
            return http.Response('[]', 200);
          default:
            return http.Response(
              jsonEncode([
                {
                  'id': '30fd83fd-4be5-4492-a4ef-fe2dc096ceaa',
                  'title': 'Proyek API',
                  'description': 'Data dari backend.',
                  'tech_stack': 'Flutter',
                  'project_url': 'https://example.com',
                },
              ]),
              200,
            );
        }
      }),
    );
    addTearDown(api.close);
    await tester.pumpWidget(MyApp(apiClient: api));
    await tester.tap(find.text('Lihat Proyek'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(requests, hasLength(1));

    initialResponse.complete(http.Response('{}', 503));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();
    expect(find.text('Belum ada proyek.'), findsOneWidget);
    expect(requests, hasLength(2));

    await tester.drag(find.byType(ListView), const Offset(0, 400));
    await tester.pumpAndSettle();
    expect(requests, hasLength(3));
    await tester.tap(find.text('Proyek API'));
    await tester.pumpAndSettle();
    expect(find.byType(ProjectDetailScreen), findsOneWidget);
    expect(find.text('Data dari backend.'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(requests, hasLength(3));
    for (final request in requests) {
      expect(request.method, 'GET');
      expect(request.headers, isNot(contains('authorization')));
    }
  });

  testWidgets(
    'Muat ulang proyek dan detail SelectionArea aman pada 320px skala 200%',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      var getCount = 0;
      final api = ApiClient(
        client: MockClient((_) async {
          getCount += 1;
          return http.Response(
            jsonEncode([
              {
                'id': '30fd83fd-4be5-4492-a4ef-fe2dc096ceaa',
                'title': 'Proyek Panjang Responsif Portfolio Mobile',
                'description': 'Deskripsi ringkas untuk uji 320px skala 200%.',
                'tech_stack': 'Flutter, Django DRF',
                'project_url': 'https://example.com/projects/responsive-mobile',
              },
            ]),
            200,
          );
        }),
      );
      addTearDown(api.close);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
          child: MyApp(apiClient: api),
        ),
      );
      await tester.pumpAndSettle();

      final projectCard = find.text('Lihat Proyek');
      await tester.ensureVisible(projectCard);
      await tester.pumpAndSettle();
      await tester.tap(projectCard.hitTestable());
      await tester.pumpAndSettle();
      expect(getCount, 1);
      expect(tester.takeException(), isNull);

      await tester.tap(find.byTooltip('Muat ulang'));
      await tester.pumpAndSettle();
      expect(getCount, 2);

      final detailTarget = find.text(
        'Proyek Panjang Responsif Portfolio Mobile',
      );
      await tester.dragUntilVisible(
        detailTarget,
        find.byType(ListView),
        const Offset(0, -150),
      );
      await tester.pumpAndSettle();
      await tester.tap(detailTarget.hitTestable());
      await tester.pumpAndSettle();
      expect(find.byType(ProjectDetailScreen), findsOneWidget);
      expect(find.byType(SelectionArea), findsOneWidget);
      expect(find.byType(SelectableText), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
