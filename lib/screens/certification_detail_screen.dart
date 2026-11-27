import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/certification.dart';
import 'package:myportofolio_mobile/theme/app_tokens.dart';

class CertificationDetailScreen extends StatelessWidget {
  const CertificationDetailScreen({required this.certification, super.key});

  final Certification certification;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final expiration = certification.expirationDate ?? 'Tidak kedaluwarsa';
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Sertifikasi')),
      body: SelectionArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.base),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: AppSpacing.base,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: AppSpacing.sm,
                              runSpacing: AppSpacing.xs,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  'CREDENTIALS & LICENSES',
                                  style: textTheme.labelSmall,
                                ),
                                if (certification.expirationDate == null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm,
                                      vertical: AppSpacing.xs,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceElevated,
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.sm,
                                      ),
                                      border: Border.all(color: AppColors.line),
                                    ),
                                    child: Text(
                                      'Tanpa kedaluwarsa',
                                      style: textTheme.labelSmall,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              certification.name,
                              style: textTheme.headlineMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'INFORMASI KREDENSIAL',
                              style: textTheme.labelSmall,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _detailRow(
                              textTheme,
                              icon: Icons.apartment_outlined,
                              label: 'Lembaga Penerbit',
                              value: certification.issuingOrganization,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: AppSpacing.md,
                              ),
                              child: Divider(),
                            ),
                            _detailRow(
                              textTheme,
                              icon: Icons.badge_outlined,
                              label: 'ID Kredensial',
                              value: certification.credentialId,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: AppSpacing.md,
                              ),
                              child: Divider(),
                            ),
                            _detailRow(
                              textTheme,
                              icon: Icons.calendar_today_outlined,
                              label: 'Tanggal Terbit',
                              value: certification.issueDate,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: AppSpacing.md,
                              ),
                              child: Divider(),
                            ),
                            _detailRow(
                              textTheme,
                              icon: Icons.event_available_outlined,
                              label: 'Tanggal Kedaluwarsa',
                              value: expiration,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: AppSpacing.md,
                              ),
                              child: Divider(),
                            ),
                            _detailRow(
                              textTheme,
                              icon: Icons.link,
                              label: 'URL Kredensial',
                              value: certification.credentialUrl,
                              accentValue: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(
    TextTheme textTheme, {
    required IconData icon,
    required String label,
    required String value,
    bool accentValue = false,
  }) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: AppSpacing.md,
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Icon(icon, size: 18, color: AppColors.accent),
      ),
      Expanded(
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '$label: ',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextSpan(
                text: value,
                style: textTheme.bodyLarge?.copyWith(
                  color: accentValue ? AppColors.accent : AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
