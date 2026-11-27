import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/certification_form.dart';
import 'package:myportofolio_mobile/screens/certification_list_screen.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';
import 'package:myportofolio_mobile/theme/app_tokens.dart';
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
      AppColors.accent,
      destination: ProjectListScreen(),
    ),
    ItemHomepage(
      'Tambah Proyek',
      Icons.add_circle,
      AppColors.accentPressed,
      destination: ProjectFormPage(),
      requiresLogin: true,
    ),
    ItemHomepage('Logout', Icons.logout, AppColors.danger, onPressed: signOut),
    ItemHomepage(
      'Tambah Sertifikasi',
      Icons.workspace_premium,
      AppColors.accentSlate,
      destination: CertificationFormPage(),
      requiresLogin: true,
    ),
    ItemHomepage(
      'Lihat Sertifikasi',
      Icons.card_membership,
      AppColors.surfaceElevated,
      destination: CertificationListScreen(),
    ),
  ];

  Widget _heroAvatar(BuildContext context, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.avatar),
        border: Border.all(color: AppColors.accent, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.avatar - 2),
        child: Image.asset(
          'assets/img/profile.png',
          fit: BoxFit.cover,
          semanticLabel: 'Foto profil $nama',
          errorBuilder: (_, _, _) => Center(
            child: Text(
              'GJ',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(color: AppColors.accent),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Flexible(
              child: Text('MyPortfolio', overflow: TextOverflow.ellipsis),
            ),
            Text('.', style: TextStyle(color: AppColors.accent)),
          ],
        ),
      ),
      drawer: const LeftDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppLayout.maxHomeWidth),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final textScale =
                    MediaQuery.textScalerOf(context).scale(14) / 14;
                final narrow = constraints.maxWidth < 360 || textScale > 1.4;
                final columns = constraints.maxWidth < 360 && textScale > 1.4
                    ? 1
                    : narrow
                    ? 2
                    : 3;
                final cardExtent = 112 + (textScale - 1).clamp(0.0, 1.5) * 64;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.base),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'INFORMATION SYSTEMS · UI',
                                      style: textTheme.labelSmall,
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    InfoCard(title: 'Name', content: nama),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              _heroAvatar(context, narrow ? 54 : 68),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: [
                              InfoCard(title: 'NPM', content: npm, chip: true),
                              InfoCard(
                                title: 'Class',
                                content: kelas,
                                chip: true,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text('AKSES PORTOFOLIO', style: textTheme.labelSmall),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Selamat datang di MyPortfolio Mobile!',
                      style: textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    GridView.builder(
                      primary: false,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: AppSpacing.md,
                        mainAxisSpacing: AppSpacing.md,
                        mainAxisExtent: cardExtent,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) => ItemCard(items[index]),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String content;
  final bool chip;

  const InfoCard({
    super.key,
    required this.title,
    required this.content,
    this.chip = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    if (!chip) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
          ),
          Text(content, style: textTheme.titleLarge),
        ],
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
          ),
          Text(
            content,
            style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
