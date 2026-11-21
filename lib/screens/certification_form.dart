import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

class CertificationFormPage extends StatefulWidget {
  const CertificationFormPage({super.key});

  @override
  State<CertificationFormPage> createState() => _CertificationFormPageState();
}

class _CertificationFormPageState extends State<CertificationFormPage> {
  static final _invalidUrlCharacters = RegExp(r'[\s\\]|%(?![0-9a-fA-F]{2})');
  final _formKey = GlobalKey<FormState>();
  final _issueDateKey = GlobalKey<FormFieldState<DateTime>>();
  final _expirationDateKey = GlobalKey<FormFieldState<DateTime>>();

  String _name = '';
  String _organization = '';
  String _credentialId = '';
  String _credentialUrl = '';

  Future<void> _pickDate(FormFieldState<DateTime> field, String label) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final selected = await showDatePicker(
      context: context,
      helpText: label,
      initialDate:
          field.value ?? _issueDateKey.currentState?.value ?? DateTime.now(),
      firstDate: DateTime(1),
      lastDate: DateTime(9999, 12, 31),
    );
    if (selected != null && field.mounted) {
      field.didChange(selected);
    }
  }

  void _saveForm() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    form.save();
    FocusManager.instance.primaryFocus?.unfocus();
    final dates = MaterialLocalizations.of(context);
    final issuedOn = _issueDateKey.currentState!.value!;
    final expiresOn = _expirationDateKey.currentState!.value;
    final expirationLabel = expiresOn == null
        ? 'Tidak diisi'
        : dates.formatShortDate(expiresOn);

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ringkasan Sertifikasi'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Text('Nama Sertifikasi: $_name'),
              Text('Lembaga Penerbit: $_organization'),
              Text('ID Kredensial: $_credentialId'),
              Text('URL Kredensial: $_credentialUrl'),
              Text('Tanggal Terbit: ${dates.formatShortDate(issuedOn)}'),
              Text('Tanggal Kedaluwarsa: $expirationLabel'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _textField({
    required String label,
    required ValueChanged<String> onSaved,
    bool isUrl = false,
  }) {
    final maxLength = isUrl ? 200 : 255;
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        errorMaxLines: 2,
      ),
      keyboardType: isUrl ? TextInputType.url : TextInputType.text,
      textInputAction: isUrl ? TextInputAction.done : TextInputAction.next,
      validator: (value) {
        final text = value?.trim() ?? '';
        if (text.isEmpty) return '$label wajib diisi.';
        if (text.runes.length > maxLength) {
          return '$label maksimal $maxLength karakter.';
        }
        if (isUrl) {
          final uri = Uri.tryParse(text);
          if (uri == null ||
              (uri.scheme != 'http' && uri.scheme != 'https') ||
              uri.host.isEmpty ||
              _invalidUrlCharacters.hasMatch(text)) {
            return 'Masukkan URL HTTP atau HTTPS yang valid.';
          }
        }
        return null;
      },
      onSaved: (value) => onSaved(value!.trim()),
    );
  }

  Widget _dateField({
    required GlobalKey<FormFieldState<DateTime>> key,
    required String label,
    required FormFieldValidator<DateTime> validator,
    bool optional = false,
  }) {
    return FormField<DateTime>(
      key: key,
      validator: validator,
      builder: (field) {
        final date = field.value;
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _pickDate(field, label),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: const RoundedRectangleBorder(),
                  side: BorderSide.none,
                ),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: label,
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    border: const OutlineInputBorder(),
                    suffixIcon: const Icon(Icons.calendar_today_outlined),
                    errorText: field.errorText,
                    errorMaxLines: 2,
                  ),
                  child: Text(
                    date == null
                        ? 'Pilih tanggal'
                        : MaterialLocalizations.of(context)
                              .formatShortDate(date),
                  ),
                ),
              ),
            ),
            if (optional && date != null)
              IconButton(
                tooltip: 'Hapus tanggal kedaluwarsa',
                icon: const Icon(Icons.clear),
                onPressed: () => field.didChange(null),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Sertifikasi'),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
      ),
      drawer: const LeftDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteractionIfError,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 16,
                  children: [
                    _textField(
                      label: 'Nama Sertifikasi',
                      onSaved: (value) => _name = value,
                    ),
                    _textField(
                      label: 'Lembaga Penerbit',
                      onSaved: (value) => _organization = value,
                    ),
                    _textField(
                      label: 'ID Kredensial',
                      onSaved: (value) => _credentialId = value,
                    ),
                    _textField(
                      label: 'URL Kredensial',
                      isUrl: true,
                      onSaved: (value) => _credentialUrl = value,
                    ),
                    _dateField(
                      key: _issueDateKey,
                      label: 'Tanggal Terbit',
                      validator: (date) =>
                          date == null ? 'Tanggal Terbit wajib diisi.' : null,
                    ),
                    _dateField(
                      key: _expirationDateKey,
                      label: 'Tanggal Kedaluwarsa (opsional)',
                      optional: true,
                      validator: (date) {
                        final issuedOn = _issueDateKey.currentState?.value;
                        if (date != null &&
                            issuedOn != null &&
                            date.isBefore(issuedOn)) {
                          return 'Tanggal kedaluwarsa tidak boleh sebelum tanggal terbit.';
                        }
                        return null;
                      },
                    ),
                    FilledButton(
                      onPressed: _saveForm,
                      child: const Text('Simpan'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
