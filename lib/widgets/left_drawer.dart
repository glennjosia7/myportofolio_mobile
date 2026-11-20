import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/certification_form.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  void _openForm<T extends Widget>(BuildContext context, T page) {
    final navigator = Navigator.of(context);
    final fromHome = ModalRoute.of(context)!.isFirst;
    final alreadyOpen = context.findAncestorWidgetOfExactType<T>() != null;

    navigator.pop(); // Tutup drawer sebelum berpindah halaman.
    if (alreadyOpen) return;

    final route = MaterialPageRoute<void>(builder: (_) => page);
    if (fromHome) {
      navigator.push(route);
    } else {
      navigator.pushReplacement(route);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              final navigator = Navigator.of(context);
              navigator.pop();
              navigator.popUntil((route) => route.isFirst);
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Add Project'),
            onTap: () => _openForm(context, const ProjectFormPage()),
          ),
          ListTile(
            leading: const Icon(Icons.workspace_premium_outlined),
            title: const Text('Add Certification'),
            onTap: () => _openForm(context, const CertificationFormPage()),
          ),
        ],
      ),
    );
  }
}
