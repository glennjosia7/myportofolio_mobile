import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myportofolio_mobile/main.dart';

void main() {
  testWidgets('MyApp menampilkan AppBar MyPortfolio', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('MyPortfolio'), findsOneWidget);
  });

  testWidgets('tiga InfoCard identitas tampil', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('NPM'), findsOneWidget);
    expect(find.text('2406000001'), findsOneWidget);
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Burhan'), findsOneWidget);
    expect(find.text('Class'), findsOneWidget);
    expect(find.text('PBP A'), findsOneWidget);
  });

  testWidgets('tiga menu ItemCard tampil', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Lihat Proyek'), findsOneWidget);
    expect(find.text('Tambah Proyek'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
  });

  testWidgets('tap Lihat Proyek menampilkan SnackBar', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Lihat Proyek'));
    await tester.pump();

    expect(
      find.text('Kamu telah menekan tombol Lihat Proyek!'),
      findsOneWidget,
    );
  });

  testWidgets('tap Tambah Proyek menampilkan SnackBar', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Tambah Proyek'));
    await tester.pump();

    expect(
      find.text('Kamu telah menekan tombol Tambah Proyek!'),
      findsOneWidget,
    );
  });

  testWidgets('tap Logout menampilkan SnackBar', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Logout'));
    await tester.pump();

    expect(find.text('Kamu telah menekan tombol Logout!'), findsOneWidget);
  });
}
