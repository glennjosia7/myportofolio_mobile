import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/certification.dart';
import 'package:myportofolio_mobile/screens/certification_list_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/theme/app_tokens.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

class CertificationFormPage extends StatefulWidget {
  const CertificationFormPage({super.key, this.fromList = false});

  final bool fromList;

  @override
  State<CertificationFormPage> createState() => _CertificationFormPageState();
}

class _CertificationFormPageState extends State<CertificationFormPage> {
  static final _invalidUrlCharacters = RegExp(r'[\s\\]|%(?![0-9a-fA-F]{2})');
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _organizationController = TextEditingController();
  final _credentialIdController = TextEditingController();
  final _credentialUrlController = TextEditingController();
  final _issueDateKey = GlobalKey<FormFieldState<DateTime>>();
  final _expirationDateKey = GlobalKey<FormFieldState<DateTime>>();
  bool _submitting = false;
  bool _createdAny = false;

  @override
  void dispose() {
    for (final controller in [
      _nameController,
      _organizationController,
      _credentialIdController,
      _credentialUrlController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  String _formatApiDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

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

  Future<void> _saveForm() async {
    final form = _formKey.currentState;
    if (_submitting || form == null || !form.validate()) return;

    FocusManager.instance.primaryFocus?.unfocus();
    final issuedOn = _issueDateKey.currentState!.value!;
    final expiresOn = _expirationDateKey.currentState!.value;
    final draft = Certification(
      name: _nameController.text.trim(),
      issuingOrganization: _organizationController.text.trim(),
      issueDate: _formatApiDate(issuedOn),
      expirationDate: expiresOn == null ? null : _formatApiDate(expiresOn),
      credentialId: _credentialIdController.text.trim(),
      credentialUrl: _credentialUrlController.text.trim(),
    );

    final auth = context.read<AuthState>();
    final api = context.read<ApiClient>();
    setState(() => _submitting = true);
    String? token;
    try {
      if (!await ensureLoggedIn(context) || !mounted) return;
      token = auth.token;
      if (token == null) return;
      final created = await api.createCertification(draft, token: token);
      if (!mounted) return;
      _createdAny = true;
      for (final controller in [
        _nameController,
        _organizationController,
        _credentialIdController,
        _credentialUrlController,
      ]) {
        controller.clear();
      }
      form.reset();

      final expirationLabel = created.expirationDate ?? 'Tidak diisi';
      final openList = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Row(
            spacing: AppSpacing.sm,
            children: [
              Icon(Icons.check_circle_outline, color: AppColors.success),
              Expanded(child: Text('Sertifikasi berhasil ditambahkan!')),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Text('Nama Sertifikasi: ${created.name}'),
                Text('Lembaga Penerbit: ${created.issuingOrganization}'),
                Text('ID Kredensial: ${created.credentialId}'),
                Text('URL Kredensial: ${created.credentialUrl}'),
                Text('Tanggal Terbit: ${created.issueDate}'),
                Text('Tanggal Kedaluwarsa: $expirationLabel'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Tutup'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Lihat Daftar'),
            ),
          ],
        ),
      );
      if (openList == true && mounted) {
        if (widget.fromList) {
          Navigator.pop(context, true);
        } else {
          await Navigator.of(context).pushReplacement<void, void>(
            MaterialPageRoute(builder: (_) => const CertificationListScreen()),
          );
        }
      }
    } on ApiException catch (error) {
      if (error.statusCode == 401 && token != null) {
        auth.invalidate(token);
        if (!mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(error.message)));
        await ensureLoggedIn(context);
        return;
      }
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Widget _textField({
    required String label,
    required TextEditingController controller,
    bool isUrl = false,
  }) {
    final maxLength = isUrl ? 200 : 255;
    return TextFormField(
      controller: controller,
      enabled: !_submitting,
      decoration: InputDecoration(labelText: label, errorMaxLines: 4),
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
    );
  }

  Widget _dateField({
    required GlobalKey<FormFieldState<DateTime>> key,
    required String label,
    required FormFieldValidator<DateTime> validator,
    bool optional = false,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return FormField<DateTime>(
      key: key,
      validator: validator,
      builder: (field) {
        final date = field.value;
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _submitting ? null : () => _pickDate(field, label),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  side: BorderSide.none,
                ),
                child: InputDecorator(
                  decoration: InputDecoration(
                    enabled: !_submitting,
                    labelText: label,
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    suffixIcon: Icon(
                      Icons.calendar_today_outlined,
                      color: _submitting ? AppColors.muted : AppColors.accent,
                    ),
                    errorText: field.errorText,
                    errorMaxLines: 4,
                  ),
                  child: Text(
                    date == null
                        ? 'Pilih tanggal'
                        : MaterialLocalizations.of(context)
                              .formatShortDate(date),
                    style: textTheme.bodyLarge?.copyWith(
                      color: date == null ? AppColors.muted : AppColors.ink,
                    ),
                  ),
                ),
              ),
            ),
            if (optional && date != null)
              IconButton(
                tooltip: 'Hapus tanggal kedaluwarsa',
                icon: const Icon(Icons.clear, color: AppColors.muted),
                onPressed: _submitting ? null : () => field.didChange(null),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return PopScope(
      canPop: !_submitting && !_createdAny,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_submitting) {
          Navigator.pop(context, _createdAny);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Tambah Sertifikasi')),
        drawer: _submitting ? null : const LeftDrawer(),
        drawerEnableOpenDragGesture: !_submitting,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.base,
              AppSpacing.base,
              AppSpacing.base,
              AppSpacing.formBottomInset,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppLayout.maxFormWidth,
                ),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteractionIfError,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: AppSpacing.base,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CREDENTIALS & LICENSES',
                            style: textTheme.labelSmall,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text.rich(
                            TextSpan(
                              text: 'Tambah Sertifikasi',
                              style: textTheme.headlineMedium,
                              children: const [
                                TextSpan(
                                  text: '.',
                                  style: TextStyle(color: AppColors.accent),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'INFORMASI SERTIFIKASI',
                        style: textTheme.labelSmall,
                      ),
                      _textField(
                        label: 'Nama Sertifikasi',
                        controller: _nameController,
                      ),
                      _textField(
                        label: 'Lembaga Penerbit',
                        controller: _organizationController,
                      ),
                      Text('REFERENSI KREDENSIAL', style: textTheme.labelSmall),
                      _textField(
                        label: 'ID Kredensial',
                        controller: _credentialIdController,
                      ),
                      _textField(
                        label: 'URL Kredensial',
                        controller: _credentialUrlController,
                        isUrl: true,
                      ),
                      Text('MASA BERLAKU', style: textTheme.labelSmall),
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
                        onPressed: _submitting ? null : _saveForm,
                        child: Text(_submitting ? 'Menyimpan…' : 'Simpan'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
