import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

Future<bool> ensureLoggedIn(BuildContext context) async {
  final auth = context.read<AuthState>();
  if (auth.isLoggedIn) return true;
  final result = await Navigator.of(context)
      .push<bool>(MaterialPageRoute(builder: (_) => const LoginScreen()));
  return result == true && auth.isLoggedIn;
}

Future<void> signOut(BuildContext context) async {
  final auth = context.read<AuthState>();
  final messenger = ScaffoldMessenger.of(context);
  if (!auth.isLoggedIn) {
    messenger.showSnackBar(const SnackBar(content: Text('Anda belum masuk.')));
    return;
  }
  var message = 'Anda telah keluar.';
  try {
    await auth.logout();
  } on ApiException {
    message =
        'Sesi lokal ditutup. Pencabutan token di server belum terkonfirmasi.';
  }
  if (messenger.mounted) {
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }
}
