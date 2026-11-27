import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/certification.dart';
import 'package:myportofolio_mobile/screens/certification_detail_screen.dart';
import 'package:myportofolio_mobile/screens/certification_form.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/theme/app_tokens.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/state_views.dart';
import 'package:provider/provider.dart';

class CertificationListScreen extends StatefulWidget {
  const CertificationListScreen({super.key});

  @override
  State<CertificationListScreen> createState() =>
      _CertificationListScreenState();
}

class _CertificationListScreenState extends State<CertificationListScreen> {
  late Future<List<Certification>> _certifications;
  bool _navigating = false;

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
    if (_navigating) return;
    _navigating = true;
    try {
      if (!await ensureLoggedIn(context) || !mounted) return;
      final created = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => const CertificationFormPage(fromList: true),
        ),
      );
      if (created == true && mounted) {
        await _refresh();
      }
    } finally {
      _navigating = false;
    }
  }

  Future<void> _openDetail(Certification certification) async {
    if (_navigating) return;
    _navigating = true;
    try {
      await Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) =>
              CertificationDetailScreen(certification: certification),
        ),
      );
    } finally {
      _navigating = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Sertifikasi'),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
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
            return ErrorStateView(
              message: error is ApiException
                  ? error.message
                  : 'Daftar sertifikasi tidak dapat dimuat.',
              onRetry: _refresh,
            );
          }
          final certifications = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.base),
              itemCount: certifications.isEmpty ? 2 : certifications.length + 1,
              itemBuilder: (context, index) => Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppLayout.maxHomeWidth,
                  ),
                  child: index == 0
                      ? _buildHeader(textTheme, certifications.length)
                      : certifications.isEmpty
                      ? const EmptyStateView(
                          icon: Icons.workspace_premium_outlined,
                          title: 'Belum ada sertifikasi.',
                          subtitle: 'Tarik ke bawah atau tekan Muat ulang untuk memeriksa data terbaru.',
                        )
                      : _buildCertificationCard(
                          textTheme,
                          certifications[index - 1],
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(TextTheme textTheme, int count) => Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CREDENTIALS & LICENSES', style: textTheme.labelSmall),
          const SizedBox(height: AppSpacing.xs),
          Text.rich(
            TextSpan(
              text: 'Sertifikasi',
              style: textTheme.headlineMedium,
              children: const [
                TextSpan(
                  text: '.',
                  style: TextStyle(color: AppColors.accent),
                ),
              ],
            ),
          ),
          if (count > 0) ...[
            const SizedBox(height: AppSpacing.xs),
            Text('$count sertifikasi tersedia', style: textTheme.bodySmall),
          ],
        ],
      ),
    ),
  );

  Widget _buildCertificationCard(
    TextTheme textTheme,
    Certification certification,
  ) {
    final validity = certification.expirationDate == null
        ? 'Terbit: ${certification.issueDate}'
        : 'Terbit: ${certification.issueDate} | Berakhir: ${certification.expirationDate}';
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _openDetail(certification),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        certification.issuingOrganization.toUpperCase(),
                        style: textTheme.labelSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(certification.name, style: textTheme.titleMedium),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: AppSpacing.xs,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Icon(
                              Icons.calendar_today_outlined,
                              size: 14,
                              color: AppColors.muted,
                            ),
                          ),
                          Expanded(
                            child: Text(validity, style: textTheme.bodySmall),
                          ),
                        ],
                      ),
                      if (certification.expirationDate == null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            border: Border.all(color: AppColors.line),
                          ),
                          child: Text(
                            'Tanpa kedaluwarsa',
                            style: textTheme.labelSmall,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.muted,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
