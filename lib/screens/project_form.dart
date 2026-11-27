import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/theme/app_tokens.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _stack = TextEditingController();
  final _url = TextEditingController();
  final _imageUrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    for (final field in [_title, _description, _stack, _url, _imageUrl]) {
      field.dispose();
    }
    super.dispose();
  }

  String? _validateUrl(String? value, int limit) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    if (text.runes.length > limit) return 'Tautan maksimal $limit karakter.';
    final uri = Uri.tryParse(text);
    if (uri == null ||
        uri.host.isEmpty ||
        !['http', 'https'].contains(uri.scheme) ||
        RegExp(r'[\s\\]|%(?![0-9a-fA-F]{2})').hasMatch(text)) {
      return 'Masukkan URL HTTP atau HTTPS yang valid.';
    }
    return null;
  }

  Widget _field({
    required String id,
    required String label,
    required TextEditingController controller,
    required FormFieldValidator<String> validator,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) => TextFormField(
    key: Key(id),
    controller: controller,
    enabled: !_submitting,
    maxLines: maxLines,
    keyboardType: keyboardType,
    decoration: InputDecoration(
      labelText: label,
      alignLabelWithHint: maxLines > 1,
      errorMaxLines: 4,
    ),
    validator: validator,
  );

  Future<void> _saveForm() async {
    if (_submitting || !_formKey.currentState!.validate()) return;
    final auth = context.read<AuthState>();
    final api = context.read<ApiClient>();
    final draft = Project(
      title: _title.text.trim(),
      description: _description.text.trim(),
      techStack: _stack.text.trim(),
      projectUrl: _url.text.trim(),
      projectImageUrl: _imageUrl.text.trim(),
    );
    setState(() => _submitting = true);
    String? token;
    try {
      if (!await ensureLoggedIn(context) || !mounted) return;
      token = auth.token;
      if (token == null) return;
      final project = await api.createProject(draft, token: token);
      if (!mounted) return;
      _formKey.currentState!.reset();
      for (final field in [_title, _description, _stack, _url, _imageUrl]) {
        field.clear();
      }
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            spacing: AppSpacing.sm,
            children: [
              Icon(Icons.check_circle_outline, color: AppColors.success),
              Expanded(child: Text('Proyek berhasil ditambahkan!')),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.xs,
              children: [
                Text('Nama Proyek: ${project.title}'),
                Text('Deskripsi: ${project.description}'),
                Text('Teknologi: ${project.techStack}'),
                Text('Tautan: ${project.projectUrl}'),
                Text('URL Gambar: ${project.projectImageUrl}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } on ApiException catch (error) {
      if (error.statusCode == 401 && token != null) auth.invalidate(token);
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String? _required(String? value, String label, {int? limit}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return '$label tidak boleh kosong!';
    if (limit != null && text.runes.length > limit) {
      return '$label maksimal $limit karakter.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return PopScope(
      canPop: !_submitting,
      child: Scaffold(
        appBar: AppBar(title: const Text('Add Project Form')),
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
                  child: Column(
                    spacing: AppSpacing.base,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('KARYA BARU', style: textTheme.labelSmall),
                          const SizedBox(height: AppSpacing.xs),
                          Text.rich(
                            TextSpan(
                              text: 'Tambah Proyek',
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
                      Text('INFORMASI PROYEK', style: textTheme.labelSmall),
                      _field(
                        id: 'projectNameField',
                        label: 'Nama Proyek',
                        controller: _title,
                        validator: (value) =>
                            _required(value, 'Nama proyek', limit: 255),
                      ),
                      _field(
                        id: 'descriptionField',
                        label: 'Deskripsi Proyek',
                        controller: _description,
                        maxLines: 5,
                        validator: (value) =>
                            _required(value, 'Deskripsi proyek'),
                      ),
                      _field(
                        id: 'technologiesField',
                        label: 'Teknologi yang Digunakan',
                        controller: _stack,
                        validator: (value) =>
                            _required(value, 'Teknologi', limit: 255),
                      ),
                      const Divider(),
                      Text(
                        'TAUTAN & MEDIA (OPSIONAL)',
                        style: textTheme.labelSmall,
                      ),
                      _field(
                        id: 'projectLinkField',
                        label: 'URL Proyek (opsional)',
                        controller: _url,
                        keyboardType: TextInputType.url,
                        validator: (value) => _validateUrl(value, 200),
                      ),
                      _field(
                        id: 'projectImageField',
                        label: 'URL Gambar (opsional)',
                        controller: _imageUrl,
                        keyboardType: TextInputType.url,
                        validator: (value) => _validateUrl(value, 500),
                      ),
                      FilledButton(
                        key: const Key('saveButton'),
                        onPressed: _submitting ? null : _saveForm,
                        child: Text(_submitting ? 'Memproses…' : 'Save'),
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
