import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/theme/app_tokens.dart';

class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({required this.project, super.key});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final image = Uri.tryParse(project.projectImageUrl);
    final safeImage =
        image != null &&
        image.host.isNotEmpty &&
        (image.scheme == 'http' || image.scheme == 'https');
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Proyek')),
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
                    if (safeImage)
                      Card(
                        clipBehavior: Clip.antiAlias,
                        child: Image.network(
                          image.toString(),
                          height: 240,
                          fit: BoxFit.contain,
                          semanticLabel: 'Gambar proyek ${project.title}',
                          errorBuilder: (_, _, _) => const Padding(
                            padding: EdgeInsets.all(AppSpacing.base),
                            child: Text('Gambar tidak dapat dimuat.'),
                          ),
                        ),
                      )
                    else if (project.projectImageUrl.isNotEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.base),
                          child: Text('URL gambar tidak valid.'),
                        ),
                      ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PROYEK PORTOFOLIO',
                              style: textTheme.labelSmall,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              project.title,
                              style: textTheme.headlineMedium,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              project.description,
                              style: textTheme.bodyLarge,
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
                            Text('DETAIL PROYEK', style: textTheme.labelSmall),
                            const SizedBox(height: AppSpacing.md),
                            _detailRow(
                              textTheme,
                              icon: Icons.code,
                              label: 'Teknologi',
                              value: project.techStack,
                            ),
                            if (project.projectUrl.isNotEmpty) ...[
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: AppSpacing.md,
                                ),
                                child: Divider(),
                              ),
                              _detailRow(
                                textTheme,
                                icon: Icons.link,
                                label: 'URL Proyek',
                                value: project.projectUrl,
                                accentValue: true,
                              ),
                            ],
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
