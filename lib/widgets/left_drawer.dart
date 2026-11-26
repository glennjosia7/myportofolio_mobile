import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/certification_form.dart';
import 'package:myportofolio_mobile/screens/certification_list_screen.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:provider/provider.dart';

class LeftDrawer extends StatefulWidget {
  const LeftDrawer({super.key});

  @override
  State<LeftDrawer> createState() => _LeftDrawerState();
}

class _LeftDrawerState extends State<LeftDrawer> {
  bool _busy = false;

  void _closeDrawer(BuildContext context) {
    Scaffold.maybeOf(context)?.closeDrawer();
  }

  Future<void> _openPage<T extends Widget>(
    BuildContext context,
    T page, {
    bool requiresLogin = false,
  }) async {
    if (_busy) return;
    _busy = true;
    try {
      final navigator = Navigator.of(context);
      final fromHome = ModalRoute.of(context)!.isFirst;
      final alreadyOpen = context.findAncestorWidgetOfExactType<T>() != null;

      _closeDrawer(context);
      if (alreadyOpen) return;
      if (requiresLogin && !await ensureLoggedIn(navigator.context)) return;
      if (!navigator.mounted) return;

      final route = MaterialPageRoute<void>(builder: (_) => page);
      if (fromHome) {
        navigator.push(route);
      } else {
        // Unwind stacked subroutes so drawer navigation leaves [Home, Target].
        navigator.popUntil((r) => r.isFirst);
        navigator.push(route);
      }
    } finally {
      _busy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<AuthState>().isLoggedIn;
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.indigo),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.topLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Portfolio',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Explore personal projects and experiences!',
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            onTap: () {
              if (_busy) return;
              _busy = true;
              try {
                _closeDrawer(context);
                Navigator.of(context).popUntil((route) => route.isFirst);
              } finally {
                _busy = false;
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.folder_outlined),
            title: const Text('View Projects'),
            onTap: () => _openPage(context, const ProjectListScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Add Project'),
            onTap: () => _openPage(
              context,
              const ProjectFormPage(),
              requiresLogin: true,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.card_membership_outlined),
            title: const Text('View Certifications'),
            onTap: () => _openPage(context, const CertificationListScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.workspace_premium_outlined),
            title: const Text('Add Certification'),
            onTap: () => _openPage(
              context,
              const CertificationFormPage(),
              requiresLogin: true,
            ),
          ),
          ListTile(
            leading: Icon(isLoggedIn ? Icons.logout : Icons.login),
            title: Text(isLoggedIn ? 'Logout' : 'Login'),
            onTap: () async {
              if (_busy) return;
              _busy = true;
              try {
                final routeContext = Navigator.of(context).context;
                _closeDrawer(context);
                if (isLoggedIn) {
                  await signOut(routeContext);
                } else {
                  await ensureLoggedIn(routeContext);
                }
              } finally {
                _busy = false;
              }
            },
          ),
        ],
      ),
    );
  }
}
