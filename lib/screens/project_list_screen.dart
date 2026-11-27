import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/screens/project_detail_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/theme/app_tokens.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/state_views.dart';
import 'package:provider/provider.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  late Future<List<Project>> _projects;

  @override
  void initState() {
    super.initState();
    _projects = context.read<ApiClient>().getProjects();
  }

  Future<void> _refresh() async {
    final next = context.read<ApiClient>().getProjects();
    setState(() {
      _projects = next;
    });
    try {
      await next;
    } on ApiException {
      // FutureBuilder presents the error and retry action.
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Proyek'),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      drawer: const LeftDrawer(),
      body: FutureBuilder<List<Project>>(
        future: _projects,
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
                  : 'Daftar proyek tidak dapat dimuat.',
              onRetry: _refresh,
            );
          }
          final projects = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.base),
              itemCount: projects.isEmpty ? 2 : projects.length + 1,
              itemBuilder: (context, index) => Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppLayout.maxHomeWidth,
                  ),
                  child: index == 0
                      ? _buildHeader(textTheme, projects.length)
                      : projects.isEmpty
                      ? const EmptyStateView(
                          icon: Icons.folder_outlined,
                          title: 'Belum ada proyek.',
                          subtitle: 'Tarik ke bawah atau tekan Muat ulang untuk memeriksa data terbaru.',
                        )
                      : _buildProjectCard(
                          context,
                          textTheme,
                          projects[index - 1],
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
          Text('KARYA YANG SAYA BANGUN', style: textTheme.labelSmall),
          const SizedBox(height: AppSpacing.xs),
          Text.rich(
            TextSpan(
              text: 'Proyek',
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
            Text('$count proyek tersedia', style: textTheme.bodySmall),
          ],
        ],
      ),
    ),
  );

  Widget _buildProjectCard(
    BuildContext context,
    TextTheme textTheme,
    Project project,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.md),
    child: Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push<void>(
          MaterialPageRoute(
            builder: (_) => ProjectDetailScreen(project: project),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (project.techStack.trim().isNotEmpty) ...[
                      Text(
                        project.techStack.toUpperCase(),
                        style: textTheme.labelSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                    ],
                    Text(project.title, style: textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      project.description,
                      style: textTheme.bodyMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (project.projectUrl.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        spacing: AppSpacing.xs,
                        children: [
                          const Icon(
                            Icons.link,
                            size: 14,
                            color: AppColors.accent,
                          ),
                          Expanded(
                            child: Text(
                              project.projectUrl,
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.accent,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(Icons.chevron_right, color: AppColors.muted, size: 20),
            ],
          ),
        ),
      ),
    ),
  );
}
