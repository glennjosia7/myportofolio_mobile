import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/screens/project_detail_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
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
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Daftar Proyek')),
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
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    error is ApiException
                        ? error.message
                        : 'Daftar proyek tidak dapat dimuat.',
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
        final projects = snapshot.data!;
        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: projects.isEmpty ? 1 : projects.length,
            itemBuilder: (context, index) {
              if (projects.isEmpty) {
                return const Center(child: Text('Belum ada proyek.'));
              }
              final project = projects[index];
              return Card(
                child: ListTile(
                  title: Text(project.title),
                  subtitle: Text(
                    '${project.techStack}\n${project.description}',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (_) => ProjectDetailScreen(project: project),
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
