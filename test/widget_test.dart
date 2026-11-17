import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';

Future<void> _pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  await tester.pumpAndSettle();
}

Future<void> _openDrawer(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.menu));
  await tester.pumpAndSettle();
}

Future<void> _openFormFromCard(WidgetTester tester) async {
  await tester.tap(find.text('Tambah Proyek'));
  await tester.pumpAndSettle();
}

Future<void> _enterFormValues(
  WidgetTester tester, {
  String name = 'Project Alpha',
  String description = 'Deskripsi project alpha',
  String technologies = 'Flutter, Django',
  String link = 'https://example.com/alpha',
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
}

Future<void> _tapSave(WidgetTester tester) async {
  await tester.ensureVisible(find.byKey(const Key('saveButton')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('saveButton')));
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

  testWidgets('tiga menu ItemCard tampil dengan ikon', (tester) async {
    await _pumpApp(tester);

    expect(find.text('Lihat Proyek'), findsOneWidget);
    expect(find.text('Tambah Proyek'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
    expect(find.byIcon(Icons.folder), findsOneWidget);
    expect(find.byIcon(Icons.add_circle), findsOneWidget);
    expect(find.byIcon(Icons.logout), findsOneWidget);
  });

  testWidgets('setiap ItemCard memakai warna unik dari model', (tester) async {
    await _pumpApp(tester);

    final cards = tester.widgetList<ItemCard>(find.byType(ItemCard)).toList();
    expect(cards, hasLength(3));

    final colors = cards.map((card) => card.item.color).toList();
    expect(colors.toSet(), hasLength(3));
    expect(colors, const [
      Color(0xFF1565C0),
      Color(0xFF2E7D32),
      Color(0xFFBF360C),
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

  testWidgets('tap Lihat Proyek menampilkan SnackBar', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Lihat Proyek'));
    await tester.pump();

    expect(
      find.text('Kamu telah menekan tombol Lihat Proyek!'),
      findsOneWidget,
    );
  });

  testWidgets('tap Tambah Proyek menampilkan SnackBar lalu form', (
    tester,
  ) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Tambah Proyek'));
    await tester.pump();

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

    expect(find.text('Kamu telah menekan tombol Logout!'), findsOneWidget);
  });

  testWidgets('drawer dapat dibuka dan menampilkan dua menu', (tester) async {
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
  });

  testWidgets('drawer Add Project membuka ProjectFormPage', (tester) async {
    await _pumpApp(tester);
    await _openDrawer(tester);

    await tester.tap(find.text('Add Project'));
    await tester.pumpAndSettle();

    expect(find.byType(ProjectFormPage), findsOneWidget);
    expect(find.text('Add Project Form'), findsOneWidget);
  });

  testWidgets('drawer Home dari form kembali ke MyHomePage', (tester) async {
    await _pumpApp(tester);
    await _openDrawer(tester);
    await tester.tap(find.text('Add Project'));
    await tester.pumpAndSettle();

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

  testWidgets('lima field form dan kategori default tampil', (tester) async {
    await _pumpApp(tester);
    await _openFormFromCard(tester);

    expect(find.byKey(const Key('projectNameField')), findsOneWidget);
    expect(find.byKey(const Key('descriptionField')), findsOneWidget);
    expect(find.byKey(const Key('categoryField')), findsOneWidget);
    expect(find.byKey(const Key('technologiesField')), findsOneWidget);
    expect(find.byKey(const Key('projectLinkField')), findsOneWidget);
    expect(find.byKey(const Key('saveButton')), findsOneWidget);
    expect(find.text('Web Development'), findsOneWidget);
  });

  testWidgets('form kosong ditolak dan tidak membuka dialog', (tester) async {
    await _pumpApp(tester);
    await _openFormFromCard(tester);

    await _tapSave(tester);

    expect(find.text('Nama proyek tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Deskripsi proyek tidak boleh kosong!'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('input whitespace-only ditolak', (tester) async {
    await _pumpApp(tester);
    await _openFormFromCard(tester);

    await tester.enterText(find.byKey(const Key('projectNameField')), '   ');
    await tester.enterText(find.byKey(const Key('descriptionField')), '   ');
    await _tapSave(tester);

    expect(find.text('Nama proyek tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Deskripsi proyek tidak boleh kosong!'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('kategori dapat diubah ke Mobile Development', (tester) async {
    await _pumpApp(tester);
    await _openFormFromCard(tester);

    await tester.tap(find.byKey(const Key('categoryField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mobile Development').last);
    await tester.pumpAndSettle();

    expect(find.text('Mobile Development'), findsOneWidget);
  });

  testWidgets('form valid menampilkan lima nilai di dialog', (tester) async {
    await _pumpApp(tester);
    await _openFormFromCard(tester);
    await _enterFormValues(tester);
    await _tapSave(tester);

    expect(find.text('Proyek berhasil ditambahkan!'), findsOneWidget);
    expect(find.text('Nama Proyek: Project Alpha'), findsOneWidget);
    expect(find.text('Deskripsi: Deskripsi project alpha'), findsOneWidget);
    expect(find.text('Kategori: Web Development'), findsOneWidget);
    expect(find.text('Teknologi: Flutter, Django'), findsOneWidget);
    expect(find.text('Tautan: https://example.com/alpha'), findsOneWidget);
  });

  testWidgets('OK menutup dialog dan mereset seluruh form', (tester) async {
    await _pumpApp(tester);
    await _openFormFromCard(tester);
    await _enterFormValues(tester);
    await _tapSave(tester);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Project Alpha'), findsNothing);
    expect(find.text('Deskripsi project alpha'), findsNothing);
    expect(find.text('Flutter, Django'), findsNothing);
    expect(find.text('https://example.com/alpha'), findsNothing);
    expect(find.text('Web Development'), findsOneWidget);
  });

  testWidgets('submit setelah reset tidak memakai data lama', (tester) async {
    await _pumpApp(tester);
    await _openFormFromCard(tester);
    await _enterFormValues(tester);
    await _tapSave(tester);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await _tapSave(tester);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Nama proyek tidak boleh kosong!'), findsOneWidget);

    await _enterFormValues(
      tester,
      name: 'Project Beta',
      description: 'Deskripsi beta',
      technologies: 'Flutter',
      link: 'https://example.com/beta',
    );
    await _tapSave(tester);

    expect(find.text('Nama Proyek: Project Beta'), findsOneWidget);
    expect(find.text('Deskripsi: Deskripsi beta'), findsOneWidget);
    expect(find.text('Project Alpha'), findsNothing);
  });

  testWidgets('tidak ada overflow pada home dan form di 320x640', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pumpApp(tester);
    expect(find.text('Glenn Josia Devano'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await _openFormFromCard(tester);
    expect(find.byType(ProjectFormPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
