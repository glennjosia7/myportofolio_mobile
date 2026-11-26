import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/certification_form.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';
import 'package:provider/provider.dart';

typedef _ProjectPost = ({
  String method,
  String path,
  Map<String, dynamic> body,
  String? authorization,
  int status,
});

Future<List<_ProjectPost>> _pumpApp(
  WidgetTester tester, {
  int createStatus = 201,
  String? returnedTitle,
}) async {
  final posts = <_ProjectPost>[];
  final api = ApiClient(
    client: MockClient((request) async {
      if (request.url.path.endsWith('/auth/token/')) {
        return http.Response('{"token":"test-token"}', 200);
      }
      if (request.url.path.endsWith('/auth/logout/')) {
        return http.Response('', 204);
      }
      if (request.method == 'GET') return http.Response('[]', 200);
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      posts.add((
        method: request.method,
        path: request.url.path,
        body: body,
        authorization: request.headers['authorization'],
        status: createStatus,
      ));
      if (createStatus != 201) return http.Response('{}', createStatus);
      return http.Response(
        jsonEncode({
          'id': '30fd83fd-4be5-4492-a4ef-fe2dc096ceaa',
          ...body,
          'title': ?returnedTitle,
        }),
        createStatus,
      );
    }),
  );
  addTearDown(api.close);
  await tester.pumpWidget(MyApp(apiClient: api));
  await tester.pumpAndSettle();
  return posts;
}

void _expectProjectPost(
  _ProjectPost post,
  int status, {
  String name = 'Project Alpha',
  String description = 'Deskripsi project alpha',
  String technologies = 'Flutter, Django',
  String link = 'https://example.com/alpha',
}) {
  expect(post.method, 'POST');
  expect(post.path, '/api/v1/projects/');
  expect(post.authorization, 'Token test-token');
  expect(post.status, status);
  expect(post.body, {
    'title': name,
    'description': description,
    'tech_stack': technologies,
    'project_url': link,
    'project_image_url': 'https://example.com/alpha.png',
  });
}

Future<void> _completeLogin(WidgetTester tester) async {
  expect(find.byType(LoginScreen), findsOneWidget);
  await tester.enterText(find.byType(TextFormField).at(0), 'test-user');
  await tester.enterText(find.byType(TextFormField).at(1), 'test-password');
  final submit = find.text('Masuk');
  await tester.ensureVisible(submit);
  await tester.tap(submit);
  await tester.pumpAndSettle();
}

Future<void> _openDrawer(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.menu));
  await tester.pumpAndSettle();
}

Future<void> _openFormFromCard(WidgetTester tester) async {
  await tester.tap(find.text('Tambah Proyek'));
  await tester.pumpAndSettle();
  if (find.byType(LoginScreen).evaluate().isNotEmpty) {
    await _completeLogin(tester);
  }
}

Future<void> _enterFormValues(
  WidgetTester tester, {
  String name = 'Project Alpha',
  String description = 'Deskripsi project alpha',
  String technologies = 'Flutter, Django',
  String link = 'https://example.com/alpha',
  String image = 'https://example.com/alpha.png',
}) async {
  await tester.enterText(find.byKey(const Key('projectNameField')), name);
  await tester.enterText(
    find.byKey(const Key('descriptionField')),
    description,
  );

  await tester.ensureVisible(find.byKey(const Key('technologiesField')));
  await tester.pumpAndSettle();
  await tester.enterText(
    find.byKey(const Key('technologiesField')),
    technologies,
  );

  await tester.ensureVisible(find.byKey(const Key('projectLinkField')));
  await tester.pumpAndSettle();
  await tester.enterText(find.byKey(const Key('projectLinkField')), link);
  final imageField = find.byKey(const Key('projectImageField'));
  await tester.ensureVisible(imageField);
  await tester.enterText(imageField, image);
}

Future<void> _tapSave(WidgetTester tester) async {
  final navigationMessage = find.ancestor(
    of: find.text('Kamu telah menekan tombol Tambah Proyek!'),
    matching: find.byType(SnackBar),
  );
  if (navigationMessage.evaluate().isNotEmpty) {
    await tester.pump(tester.widget<SnackBar>(navigationMessage).duration);
    await tester.pumpAndSettle();
    expect(navigationMessage, findsNothing);
  }
  final saveButton = find.byKey(const Key('saveButton'));
  await tester.ensureVisible(saveButton);
  await tester.pumpAndSettle();
  expect(saveButton.hitTestable(), findsOneWidget);
  expect(tester.widget<FilledButton>(saveButton).onPressed, isNotNull);
  await tester.tap(saveButton.hitTestable());
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('MyApp menampilkan AppBar MyPortfolio', (tester) async {
    await _pumpApp(tester);

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('MyPortfolio'), findsOneWidget);
  });

  testWidgets('tiga InfoCard identitas personal tampil', (tester) async {
    await _pumpApp(tester);

    expect(find.text('NPM'), findsOneWidget);
    expect(find.text('2506614712'), findsOneWidget);
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Glenn Josia Devano'), findsOneWidget);
    expect(find.text('Class'), findsOneWidget);
    expect(find.text('PBP F'), findsOneWidget);
    expect(find.text('Burhan'), findsNothing);
    expect(find.text('2406000001'), findsNothing);
    expect(find.text('PBP A'), findsNothing);
  });

  testWidgets('MyHomePage tetap StatelessWidget', (tester) async {
    await _pumpApp(tester);

    final homePage = tester.widget<MyHomePage>(find.byType(MyHomePage));
    expect(homePage, isA<StatelessWidget>());
  });

  testWidgets('lima menu ItemCard tampil dengan ikon', (tester) async {
    await _pumpApp(tester);

    expect(find.text('Lihat Proyek'), findsOneWidget);
    expect(find.text('Tambah Proyek'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
    expect(find.text('Tambah Sertifikasi'), findsOneWidget);
    expect(find.text('Lihat Sertifikasi'), findsOneWidget);
    expect(find.byIcon(Icons.folder), findsOneWidget);
    expect(find.byIcon(Icons.add_circle), findsOneWidget);
    expect(find.byIcon(Icons.logout), findsOneWidget);
    expect(find.byIcon(Icons.workspace_premium), findsOneWidget);
    expect(find.byIcon(Icons.card_membership), findsOneWidget);
  });

  testWidgets('setiap ItemCard memakai warna unik dari model', (tester) async {
    await _pumpApp(tester);

    final cards = tester.widgetList<ItemCard>(find.byType(ItemCard)).toList();
    expect(cards, hasLength(5));

    final colors = cards.map((card) => card.item.color).toList();
    expect(colors.toSet(), hasLength(5));
    expect(colors, const [
      Color(0xFF1565C0),
      Color(0xFF2E7D32),
      Color(0xFFBF360C),
      Color(0xFF6A1B9A),
      Color(0xFF00695C),
    ]);

    for (final card in cards) {
      final material = tester.widget<Material>(
        find.descendant(
          of: find.byWidget(card),
          matching: find.byType(Material),
        ),
      );
      expect(material.color, card.item.color);
    }
  });

  testWidgets('Lihat Proyek menampilkan SnackBar dan daftar publik', (
    tester,
  ) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Lihat Proyek'));
    await tester.pump();

    expect(
      find.text('Kamu telah menekan tombol Lihat Proyek!'),
      findsOneWidget,
    );
    await tester.pumpAndSettle();
    expect(find.byType(ProjectListScreen), findsOneWidget);
    expect(find.text('Belum ada proyek.'), findsOneWidget);
  });

  testWidgets('Tambah Proyek meminta login sebelum membuka form', (
    tester,
  ) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Tambah Proyek'));
    await tester.pumpAndSettle();
    expect(find.byType(ProjectFormPage), findsNothing);
    await _completeLogin(tester);

    expect(
      find.text('Kamu telah menekan tombol Tambah Proyek!'),
      findsOneWidget,
    );

    await tester.pumpAndSettle();
    expect(find.byType(ProjectFormPage), findsOneWidget);
  });

  testWidgets('tap Logout menampilkan SnackBar', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Logout'));
    await tester.pump();

    expect(find.text('Anda belum masuk.'), findsOneWidget);
  });

  testWidgets('drawer menampilkan navigasi dan opsi login', (tester) async {
    await _pumpApp(tester);
    await _openDrawer(tester);

    expect(find.byType(LeftDrawer), findsOneWidget);
    expect(find.text('My Portfolio'), findsOneWidget);
    expect(
      find.text('Explore personal projects and experiences!'),
      findsOneWidget,
    );
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Add Project'), findsOneWidget);
    expect(find.text('Add Certification'), findsOneWidget);
    expect(find.text('View Certifications'), findsOneWidget);
    expect(find.text('View Projects'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('drawer Add Project membuka ProjectFormPage', (tester) async {
    await _pumpApp(tester);
    await _openDrawer(tester);

    await tester.tap(find.text('Add Project'));
    await tester.pumpAndSettle();
    if (find.byType(LoginScreen).evaluate().isNotEmpty) {
      await _completeLogin(tester);
    }

    expect(find.byType(ProjectFormPage), findsOneWidget);
    expect(find.text('Add Project Form'), findsOneWidget);
  });

  testWidgets('drawer Home dari form kembali ke MyHomePage', (tester) async {
    await _pumpApp(tester);
    await _openDrawer(tester);
    await tester.tap(find.text('Add Project'));
    await tester.pumpAndSettle();
    if (find.byType(LoginScreen).evaluate().isNotEmpty) {
      await _completeLogin(tester);
    }

    await _openDrawer(tester);
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    expect(find.byType(MyHomePage), findsOneWidget);
    expect(find.text('Glenn Josia Devano'), findsOneWidget);
  });

  testWidgets('back dari form kembali ke halaman utama', (tester) async {
    await _pumpApp(tester);
    await _openFormFromCard(tester);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.byType(MyHomePage), findsOneWidget);
  });

  testWidgets('kartu Sertifikasi membuka form dan Back kembali ke Home', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pumpApp(tester);
    final card = find.text('Tambah Sertifikasi');
    await tester.ensureVisible(card);
    await tester.pumpAndSettle();
    await tester.tap(card.hitTestable());
    await tester.pumpAndSettle();

    expect(find.byType(CertificationFormPage), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(4));
    expect(find.text('Nama Sertifikasi'), findsOneWidget);
    expect(find.text('Lembaga Penerbit'), findsOneWidget);
    expect(find.text('ID Kredensial'), findsOneWidget);
    expect(find.text('URL Kredensial'), findsOneWidget);
    expect(find.text('Tanggal Terbit'), findsOneWidget);
    expect(find.text('Tanggal Kedaluwarsa (opsional)'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(MyHomePage), findsOneWidget);
  });

  testWidgets('Add Certification dari drawer dapat kembali lewat Home', (
    tester,
  ) async {
    await _pumpApp(tester);
    await _openDrawer(tester);
    await tester.tap(find.text('Add Certification'));
    await tester.pumpAndSettle();

    expect(find.byType(CertificationFormPage), findsOneWidget);
    await _openDrawer(tester);
    expect(find.byType(LeftDrawer), findsOneWidget);
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    expect(find.byType(MyHomePage, skipOffstage: false), findsOneWidget);
    expect(
      find.byType(CertificationFormPage, skipOffstage: false),
      findsNothing,
    );
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    expect(navigator.canPop(), isFalse);
  });

  testWidgets('perpindahan antarform tidak menumpuk halaman', (tester) async {
    await _pumpApp(tester);
    await _openFormFromCard(tester);

    await _openDrawer(tester);
    await tester.tap(find.text('Add Certification'));
    await tester.pumpAndSettle();
    expect(find.byType(CertificationFormPage), findsOneWidget);
    expect(find.byType(ProjectFormPage, skipOffstage: false), findsNothing);

    await _openDrawer(tester);
    await tester.tap(find.text('Add Project'));
    await tester.pumpAndSettle();
    if (find.byType(LoginScreen).evaluate().isNotEmpty) {
      await _completeLogin(tester);
    }
    expect(find.byType(ProjectFormPage), findsOneWidget);
    expect(
      find.byType(CertificationFormPage, skipOffstage: false),
      findsNothing,
    );

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(MyHomePage), findsOneWidget);
  });

  testWidgets('memilih form Sertifikasi yang aktif mempertahankan isian', (
    tester,
  ) async {
    await _pumpApp(tester);
    final card = find.text('Tambah Sertifikasi');
    await tester.ensureVisible(card);
    await tester.pumpAndSettle();
    await tester.tap(card.hitTestable());
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Sertifikasi A');

    await _openDrawer(tester);
    await tester.tap(find.text('Add Certification'));
    await tester.pumpAndSettle();

    expect(find.byType(CertificationFormPage), findsOneWidget);
    expect(find.text('Sertifikasi A'), findsOneWidget);
  });

  testWidgets('lima field serializer proyek tampil', (tester) async {
    await _pumpApp(tester);
    await _openFormFromCard(tester);

    expect(find.byKey(const Key('projectNameField')), findsOneWidget);
    expect(find.byKey(const Key('descriptionField')), findsOneWidget);
    expect(find.byKey(const Key('projectImageField')), findsOneWidget);
    expect(find.byKey(const Key('technologiesField')), findsOneWidget);
    expect(find.byKey(const Key('projectLinkField')), findsOneWidget);
    expect(find.byKey(const Key('saveButton')), findsOneWidget);
  });

  testWidgets('form kosong ditolak dan tidak membuka dialog', (tester) async {
    final posts = await _pumpApp(tester);
    await _openFormFromCard(tester);

    await _tapSave(tester);

    expect(find.text('Nama proyek tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Deskripsi proyek tidak boleh kosong!'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    expect(posts, isEmpty);
  });

  testWidgets('input whitespace-only ditolak', (tester) async {
    final posts = await _pumpApp(tester);
    await _openFormFromCard(tester);

    await tester.enterText(find.byKey(const Key('projectNameField')), '   ');
    await tester.enterText(find.byKey(const Key('descriptionField')), '   ');
    await _tapSave(tester);

    expect(find.text('Nama proyek tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Deskripsi proyek tidak boleh kosong!'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    expect(posts, isEmpty);
  });

  testWidgets('URL gambar invalid ditolak sebelum POST', (tester) async {
    final posts = await _pumpApp(tester);
    await _openFormFromCard(tester);
    await _enterFormValues(tester, image: 'javascript:alert(1)');
    await _tapSave(tester);
    expect(
      find.text('Masukkan URL HTTP atau HTTPS yang valid.'),
      findsOneWidget,
    );
    expect(find.byType(AlertDialog), findsNothing);
    expect(posts, isEmpty);
  });

  testWidgets('membatalkan login menahan navigasi terproteksi', (tester) async {
    await _pumpApp(tester);
    await tester.tap(find.text('Tambah Proyek'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(MyHomePage), findsOneWidget);
    expect(find.byType(ProjectFormPage), findsNothing);
  });

  for (final status in [401, 403]) {
    testWidgets('POST $status mempertahankan isian tanpa dialog sukses', (
      tester,
    ) async {
      final posts = await _pumpApp(tester, createStatus: status);
      await _openFormFromCard(tester);
      await _enterFormValues(tester);
      await _tapSave(tester);
      _expectProjectPost(posts.single, status);
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Project Alpha'), findsOneWidget);
      expect(
        find.text(
          status == 401
              ? 'Sesi tidak valid. Silakan masuk lagi.'
              : 'Akun ini tidak memiliki izin untuk tindakan tersebut.',
        ),
        findsOneWidget,
      );
      final auth = tester
          .element(find.byType(ProjectFormPage))
          .read<AuthState>();
      expect(auth.isLoggedIn, status == 403);
    });
  }

  testWidgets('Logout memanggil endpoint dan mengubah menu drawer', (
    tester,
  ) async {
    await _pumpApp(tester);
    await _openFormFromCard(tester);
    await _openDrawer(tester);
    await tester.tap(
      find.descendant(
        of: find.byType(LeftDrawer),
        matching: find.text('Logout'),
      ),
    );
    await tester.pumpAndSettle();
    await _openDrawer(tester);
    expect(
      find.descendant(
        of: find.byType(LeftDrawer),
        matching: find.text('Login'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('form valid menampilkan lima nilai di dialog', (tester) async {
    final posts = await _pumpApp(tester, returnedTitle: 'Project Alpha API');
    await _openFormFromCard(tester);
    await _enterFormValues(tester);
    await _tapSave(tester);

    _expectProjectPost(posts.single, 201);
    expect(find.text('Proyek berhasil ditambahkan!'), findsOneWidget);
    expect(find.text('Nama Proyek: Project Alpha API'), findsOneWidget);
    expect(find.text('Deskripsi: Deskripsi project alpha'), findsOneWidget);
    expect(
      find.text('URL Gambar: https://example.com/alpha.png'),
      findsOneWidget,
    );
    expect(find.text('Teknologi: Flutter, Django'), findsOneWidget);
    expect(find.text('Tautan: https://example.com/alpha'), findsOneWidget);
  });

  testWidgets('OK menutup dialog dan mereset seluruh form', (tester) async {
    final posts = await _pumpApp(tester);
    await _openFormFromCard(tester);
    await _enterFormValues(tester);
    await _tapSave(tester);
    _expectProjectPost(posts.single, 201);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Project Alpha'), findsNothing);
    expect(find.text('Deskripsi project alpha'), findsNothing);
    expect(find.text('Flutter, Django'), findsNothing);
    expect(find.text('https://example.com/alpha'), findsNothing);
  });

  testWidgets('submit setelah reset tidak memakai data lama', (tester) async {
    final posts = await _pumpApp(tester);
    await _openFormFromCard(tester);
    await _enterFormValues(tester);
    await _tapSave(tester);
    _expectProjectPost(posts.single, 201);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await _tapSave(tester);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Nama proyek tidak boleh kosong!'), findsOneWidget);
    expect(posts, hasLength(1));

    await _enterFormValues(
      tester,
      name: 'Project Beta',
      description: 'Deskripsi beta',
      technologies: 'Flutter',
      link: 'https://example.com/beta',
    );
    await _tapSave(tester);

    expect(posts, hasLength(2));
    _expectProjectPost(
      posts.last,
      201,
      name: 'Project Beta',
      description: 'Deskripsi beta',
      technologies: 'Flutter',
      link: 'https://example.com/beta',
    );
    expect(find.text('Nama Proyek: Project Beta'), findsOneWidget);
    expect(find.text('Deskripsi: Deskripsi beta'), findsOneWidget);
    expect(find.text('Project Alpha'), findsNothing);
  });

  for (final size in const [
    Size(320, 640),
    Size(390, 844),
    Size(768, 1024),
    Size(1280, 800),
  ]) {
    testWidgets('home dan Save dapat dipakai pada ${size.width.toInt()} px', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final posts = await _pumpApp(tester);
      expect(find.text('Glenn Josia Devano'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await _openFormFromCard(tester);
      expect(find.byType(ProjectFormPage), findsOneWidget);
      await _tapSave(tester);
      expect(find.text('Nama proyek tidak boleh kosong!'), findsOneWidget);
      expect(posts, isEmpty);
      expect(tester.takeException(), isNull);
    });
  }
}
