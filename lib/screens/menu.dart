import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/certification_form.dart';
import 'package:myportofolio_mobile/screens/certification_list_screen.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  final String npm = '2506614712';
  final String nama = 'Glenn Josia Devano';
  final String kelas = 'PBP F';

  final List<ItemHomepage> items = const [
    ItemHomepage(
      'Lihat Proyek',
      Icons.folder,
      Color(0xFF1565C0),
      destination: ProjectListScreen(),
    ),
    ItemHomepage(
      'Tambah Proyek',
      Icons.add_circle,
      Color(0xFF2E7D32),
      destination: ProjectFormPage(),
      requiresLogin: true,
    ),
    ItemHomepage('Logout', Icons.logout, Color(0xFFBF360C), onPressed: signOut),
    ItemHomepage(
      'Tambah Sertifikasi',
      Icons.workspace_premium,
      Color(0xFF6A1B9A),
      destination: CertificationFormPage(),
      requiresLogin: true,
    ),
    ItemHomepage(
      'Lihat Sertifikasi',
      Icons.card_membership,
      Color(0xFF00695C),
      destination: CertificationListScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MyPortfolio',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const LeftDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  child: InfoCard(title: 'NPM', content: npm),
                ),
                Expanded(
                  child: InfoCard(title: 'Name', content: nama),
                ),
                Expanded(
                  child: InfoCard(title: 'Class', content: kelas),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Center(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Text(
                      'Selamat datang di MyPortfolio Mobile!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final largeText =
                          MediaQuery.textScalerOf(context).scale(14) > 20;
                      final columns = constraints.maxWidth < 360 || largeText
                          ? 2
                          : 3;
                      return GridView.count(
                        primary: false,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(20),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        crossAxisCount: columns,
                        childAspectRatio: columns == 2 ? 1.0 : 0.8,
                        shrinkWrap: true,
                        children: items.map((ItemHomepage item) {
                          return ItemCard(item);
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String content;

  const InfoCard({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            Text(content, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
