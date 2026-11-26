import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/certification.dart';

class CertificationDetailScreen extends StatelessWidget {
  const CertificationDetailScreen({required this.certification, super.key});

  final Certification certification;

  @override
  Widget build(BuildContext context) {
    final expiration = certification.expirationDate ?? 'Tidak kedaluwarsa';
    return Scaffold(
      appBar: AppBar(title: Text(certification.name)),
      body: SelectionArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              certification.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text('Lembaga Penerbit: ${certification.issuingOrganization}'),
            const SizedBox(height: 12),
            Text('ID Kredensial: ${certification.credentialId}'),
            const SizedBox(height: 12),
            Text('Tanggal Terbit: ${certification.issueDate}'),
            const SizedBox(height: 12),
            Text('Tanggal Kedaluwarsa: $expiration'),
            const SizedBox(height: 12),
            Text('URL Kredensial: ${certification.credentialUrl}'),
          ],
        ),
      ),
    );
  }
}
