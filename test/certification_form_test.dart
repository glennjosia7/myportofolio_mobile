import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/certification_form.dart';

const _summary = 'Ringkasan Sertifikasi';
const _expirationLabel = 'Tanggal Kedaluwarsa (opsional)';

Future<void> _openForm(WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  await tester.pumpAndSettle();
  await _tapVisible(tester, find.text('Tambah Sertifikasi'));
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

Future<void> _save(WidgetTester tester) =>
    _tapVisible(tester, find.text('Simpan'));

void main() {
  testWidgets('input wajib kosong atau whitespace ditolak per field', (
    tester,
  ) async {
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
    expect(find.text(_summary), findsNothing);
  });

  testWidgets('batas panjang teks dan URL diterapkan per field', (
    tester,
  ) async {
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
    expect(find.text(_summary), findsNothing);
  });

  testWidgets('URL tanpa host, skema lain, dan spasi internal ditolak', (
    tester,
  ) async {
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
      expect(find.text(_summary), findsNothing);
    }
  });

  testWidgets('urutan tanggal diperiksa ulang saat tanggal terbit diubah', (
    tester,
  ) async {
    await _openForm(tester);
    await _fillText(tester);
    await _pickDate(tester, 'Tanggal Terbit', DateTime(2026, 11, 20));
    await _pickDate(tester, _expirationLabel, DateTime(2026, 11, 19));
    await _save(tester);
    expect(
      find.text('Tanggal kedaluwarsa tidak boleh sebelum tanggal terbit.'),
      findsOneWidget,
    );
    expect(find.text(_summary), findsNothing);

    await _pickDate(tester, 'Tanggal Terbit', DateTime(2026, 11, 19));
    await _save(tester);
    expect(find.text(_summary), findsOneWidget);
    expect(find.text('Tanggal Terbit: Nov 19, 2026'), findsOneWidget);
    expect(find.text('Tanggal Kedaluwarsa: Nov 19, 2026'), findsOneWidget);
  });

  testWidgets('dialog memuat enam nilai dan Tutup mempertahankan isian', (
    tester,
  ) async {
    await _openForm(tester);
    await _fillText(tester);
    await _pickDate(tester, 'Tanggal Terbit', DateTime(2026, 11, 20));
    await _pickDate(tester, _expirationLabel, DateTime(2027, 11, 20));
    await _save(tester);

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text(_summary), findsOneWidget);
    for (final line in [
      'Nama Sertifikasi: Flutter Associate',
      'Lembaga Penerbit: Flutter Academy',
      'ID Kredensial: FL-123',
      'URL Kredensial: https://example.com/verify/FL-123',
      'Tanggal Terbit: Nov 20, 2026',
      'Tanggal Kedaluwarsa: Nov 20, 2027',
    ]) {
      expect(find.text(line), findsOneWidget);
    }

    await tester.tap(find.text('Tutup'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(CertificationFormPage), findsOneWidget);
    expect(find.text('  Flutter Associate  '), findsOneWidget);
    expect(find.text('Nov 20, 2027'), findsOneWidget);

    await _tapVisible(tester, find.byTooltip('Hapus tanggal kedaluwarsa'));
    await _save(tester);
    expect(find.text('Tanggal Kedaluwarsa: Tidak diisi'), findsOneWidget);
  });

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
        await _openForm(tester);

        if (size.width == 320) {
          // Let the navigation SnackBar expire before testing keyboard reachability.
          final snackBar = find.byType(SnackBar);
          await tester.pump(tester.widget<SnackBar>(snackBar).duration);
          await tester.pumpAndSettle();
          expect(snackBar, findsNothing);

          await _enterText(tester, 'Nama Sertifikasi', 'Flutter Associate');
          tester.view.viewInsets = const FakeViewPadding(bottom: 280);
          addTearDown(tester.view.resetViewInsets);
          await tester.pumpAndSettle();

          // Scroll while the input remains focused and the keyboard inset is active.
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
        expect(tester.takeException(), isNull);
      },
    );
  }
}
