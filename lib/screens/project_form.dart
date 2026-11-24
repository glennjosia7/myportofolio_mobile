import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
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
      border: const OutlineInputBorder(),
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
          title: const Text('Proyek berhasil ditambahkan!'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
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
            .showSnackBar(SnackBar(content: Text(error.message)));
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
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Add Project Form'),
      backgroundColor: Colors.indigo,
      foregroundColor: Colors.white,
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
              child: Column(
                spacing: 16,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                    validator: (value) => _required(value, 'Deskripsi proyek'),
                  ),
                  _field(
                    id: 'technologiesField',
                    label: 'Teknologi yang Digunakan',
                    controller: _stack,
                    validator: (value) =>
                        _required(value, 'Teknologi', limit: 255),
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
  );
}
