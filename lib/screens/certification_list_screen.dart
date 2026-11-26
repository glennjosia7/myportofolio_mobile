import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/certification.dart';
import 'package:myportofolio_mobile/screens/certification_detail_screen.dart';
import 'package:myportofolio_mobile/screens/certification_form.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

class CertificationListScreen extends StatefulWidget {
  const CertificationListScreen({super.key});

  @override
  State<CertificationListScreen> createState() =>
      _CertificationListScreenState();
}

class _CertificationListScreenState extends State<CertificationListScreen> {
  late Future<List<Certification>> _certifications;

  @override
  void initState() {
    super.initState();
    _certifications = context.read<ApiClient>().getCertifications();
  }

  Future<void> _refresh() async {
    final next = context.read<ApiClient>().getCertifications();
    setState(() {
      _certifications = next;
    });
    try {
      await next;
    } on ApiException {
      // FutureBuilder presents the error and retry action.
    }
  }

  Future<void> _openCreateForm() async {
    if (!await ensureLoggedIn(context) || !mounted) return;
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const CertificationFormPage(fromList: true),
      ),
    );
    if (created == true && mounted) {
      await _refresh();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Daftar Sertifikasi'),
      actions: [
        IconButton(
          tooltip: 'Tambah Sertifikasi',
          icon: const Icon(Icons.add),
          onPressed: _openCreateForm,
        ),
      ],
    ),
    drawer: const LeftDrawer(),
    body: FutureBuilder<List<Certification>>(
      future: _certifications,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          final error = snapshot.error;
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    error is ApiException
                        ? error.message
                        : 'Daftar sertifikasi tidak dapat dimuat.',
                  ),
                  TextButton(
                    onPressed: _refresh,
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            ),
          );
        }
        final certifications = snapshot.data!;
        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: certifications.isEmpty ? 1 : certifications.length,
            itemBuilder: (context, index) {
              if (certifications.isEmpty) {
                return const Center(child: Text('Belum ada sertifikasi.'));
              }
              final certification = certifications[index];
              final validity = certification.expirationDate == null
                  ? 'Terbit: ${certification.issueDate}'
                  : 'Terbit: ${certification.issueDate} | Berakhir: ${certification.expirationDate}';
              return Card(
                child: ListTile(
                  title: Text(certification.name),
                  subtitle: Text(
                    '${certification.issuingOrganization}\n$validity',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (_) => CertificationDetailScreen(
                        certification: certification,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    ),
  );
}
