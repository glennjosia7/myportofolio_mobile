import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';

class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({required this.project, super.key});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final image = Uri.tryParse(project.projectImageUrl);
    final safeImage =
        image != null &&
        image.host.isNotEmpty &&
        (image.scheme == 'http' || image.scheme == 'https');
    return Scaffold(
      appBar: AppBar(title: Text(project.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (safeImage)
            Image.network(
              image.toString(),
              height: 240,
              fit: BoxFit.contain,
              semanticLabel: 'Gambar proyek ${project.title}',
              errorBuilder: (_, _, _) =>
                  const Text('Gambar tidak dapat dimuat.'),
            )
          else if (project.projectImageUrl.isNotEmpty)
            const Text('URL gambar tidak valid.'),
          Text(project.description),
          const SizedBox(height: 12),
          Text('Teknologi: ${project.techStack}'),
          if (project.projectUrl.isNotEmpty) ...[
            const SizedBox(height: 12),
            SelectableText('URL Proyek: ${project.projectUrl}'),
          ],
        ],
      ),
    );
  }
}
