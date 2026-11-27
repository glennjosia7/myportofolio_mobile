import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/theme/app_tokens.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  bool _submitting = false;
  bool _obscurePassword = true;

  Future<void> _submit() async {
    if (_submitting || !_form.currentState!.validate()) return;
    final auth = context.read<AuthState>();
    setState(() => _submitting = true);
    try {
      await auth.login(_username.trim(), _password);
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        Navigator.pop(context, true);
      }
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return PopScope(
      canPop: !_submitting,
      child: Scaffold(
        appBar: AppBar(title: const Text('Login')),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.base,
              AppSpacing.xl,
              AppSpacing.base,
              AppSpacing.formBottomInset,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppLayout.maxLoginWidth,
                ),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Form(
                      key: _form,
                      child: Column(
                        spacing: AppSpacing.base,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Column(
                            spacing: AppSpacing.xs,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AKSES PORTOFOLIO',
                                style: textTheme.labelSmall,
                              ),
                              Text.rich(
                                TextSpan(
                                  text: 'Login',
                                  style: textTheme.headlineMedium,
                                  children: const [
                                    TextSpan(
                                      text: '.',
                                      style: TextStyle(color: AppColors.accent),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'Masuk untuk menambahkan proyek atau sertifikasi ke backend Django.',
                                style: textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          TextFormField(
                            enabled: !_submitting,
                            decoration: const InputDecoration(
                              labelText: 'Username',
                              // Deep navy fill creates depth inside the elevated slate card.
                              fillColor: AppColors.paper,
                            ),
                            textInputAction: TextInputAction.next,
                            onChanged: (value) => _username = value,
                            validator: (value) => (value ?? '').trim().isEmpty
                                ? 'Username wajib diisi.'
                                : null,
                          ),
                          TextFormField(
                            enabled: !_submitting,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              fillColor: AppColors.paper,
                              suffixIcon: IconButton(
                                tooltip: _obscurePassword
                                    ? 'Tampilkan password'
                                    : 'Sembunyikan password',
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: AppColors.muted,
                                ),
                                onPressed: _submitting
                                    ? null
                                    : () => setState(
                                        () => _obscurePassword =
                                            !_obscurePassword,
                                      ),
                              ),
                            ),
                            onChanged: (value) => _password = value,
                            validator: (value) => (value ?? '').isEmpty
                                ? 'Password wajib diisi.'
                                : null,
                            onFieldSubmitted: (_) => _submit(),
                          ),
                          ElevatedButton(
                            onPressed: _submitting ? null : _submit,
                            child: _submitting
                                ? const SizedBox.square(
                                    dimension: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Masuk'),
                          ),
                        ],
                      ),
                    ),
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
