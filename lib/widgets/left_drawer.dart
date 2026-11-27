import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/certification_form.dart';
import 'package:myportofolio_mobile/screens/certification_list_screen.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/theme/app_tokens.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:provider/provider.dart';

class LeftDrawer extends StatefulWidget {
  const LeftDrawer({super.key});

  @override
  State<LeftDrawer> createState() => _LeftDrawerState();
}

class _LeftDrawerState extends State<LeftDrawer> {
  bool _busy = false;

  void _closeDrawer(BuildContext context) {
    Scaffold.maybeOf(context)?.closeDrawer();
  }

  Future<void> _openPage<T extends Widget>(
    BuildContext context,
    T page, {
    bool requiresLogin = false,
  }) async {
    if (_busy) return;
    _busy = true;
    try {
      final navigator = Navigator.of(context);
      final fromHome = ModalRoute.of(context)!.isFirst;
      final alreadyOpen = context.findAncestorWidgetOfExactType<T>() != null;

      _closeDrawer(context);
      if (alreadyOpen) return;
      if (requiresLogin && !await ensureLoggedIn(navigator.context)) return;
      if (!navigator.mounted) return;

      final route = MaterialPageRoute<void>(builder: (_) => page);
      if (fromHome) {
        navigator.push(route);
      } else {
        // Unwind stacked subroutes so drawer navigation leaves [Home, Target].
        navigator.popUntil((r) => r.isFirst);
        navigator.push(route);
      }
    } finally {
      _busy = false;
    }
  }

  Widget _sectionLabel(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.sm,
        AppSpacing.base,
        2,
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelSmall),
    );
  }

  Widget _navItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool selected,
    required VoidCallback onTap,
    Color? foregroundColor,
  }) {
    final color =
        foregroundColor ?? (selected ? AppColors.accent : AppColors.ink);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 1,
      ),
      child: ListTile(
        dense: true,
        minTileHeight: 48,
        selected: selected,
        selectedTileColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: selected
              ? const BorderSide(color: AppColors.line)
              : BorderSide.none,
        ),
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: TextStyle(
            color: color,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        trailing: selected
            ? Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<AuthState>().isLoggedIn;
    final textTheme = Theme.of(context).textTheme;
    final isHome = context.findAncestorWidgetOfExactType<MyHomePage>() != null;
    final isProjects =
        context.findAncestorWidgetOfExactType<ProjectListScreen>() != null;
    final isAddProject =
        context.findAncestorWidgetOfExactType<ProjectFormPage>() != null;
    final isCertifications =
        context.findAncestorWidgetOfExactType<CertificationListScreen>() !=
        null;
    final isAddCertification =
        context.findAncestorWidgetOfExactType<CertificationFormPage>() != null;

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.base,
                AppSpacing.base,
                AppSpacing.base,
                AppSpacing.md,
              ),
              decoration: const BoxDecoration(
                color: AppColors.paper,
                border: Border(bottom: BorderSide(color: AppColors.line)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          'My Portfolio',
                          style: textTheme.titleLarge,
                        ),
                      ),
                      Text(
                        '.',
                        style: textTheme.titleLarge?.copyWith(
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Explore personal projects and experiences!',
                    style: textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(
                        color: isLoggedIn ? AppColors.accent : AppColors.line,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: isLoggedIn
                                ? AppColors.accent
                                : AppColors.muted,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Flexible(
                          child: Text(
                            isLoggedIn ? 'Authenticated' : 'Guest Mode',
                            style: textTheme.bodySmall?.copyWith(
                              color: isLoggedIn
                                  ? AppColors.accent
                                  : AppColors.muted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _sectionLabel(context, 'PORTFOLIO'),
            _navItem(
              context,
              icon: Icons.home_outlined,
              title: 'Home',
              selected: isHome,
              onTap: () {
                if (_busy) return;
                _busy = true;
                try {
                  _closeDrawer(context);
                  Navigator.of(context).popUntil((route) => route.isFirst);
                } finally {
                  _busy = false;
                }
              },
            ),
            _navItem(
              context,
              icon: Icons.folder_outlined,
              title: 'View Projects',
              selected: isProjects,
              onTap: () => _openPage(context, const ProjectListScreen()),
            ),
            _navItem(
              context,
              icon: Icons.card_membership_outlined,
              title: 'View Certifications',
              selected: isCertifications,
              onTap: () => _openPage(context, const CertificationListScreen()),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Divider(),
            ),
            _sectionLabel(context, 'KELOLA DATA'),
            _navItem(
              context,
              icon: Icons.add_circle_outline,
              title: 'Add Project',
              selected: isAddProject,
              onTap: () => _openPage(
                context,
                const ProjectFormPage(),
                requiresLogin: true,
              ),
            ),
            _navItem(
              context,
              icon: Icons.workspace_premium_outlined,
              title: 'Add Certification',
              selected: isAddCertification,
              onTap: () => _openPage(
                context,
                const CertificationFormPage(),
                requiresLogin: true,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Divider(),
            ),
            _sectionLabel(context, 'SESI'),
            _navItem(
              context,
              icon: isLoggedIn ? Icons.logout : Icons.login,
              title: isLoggedIn ? 'Logout' : 'Login',
              selected: false,
              foregroundColor: isLoggedIn
                  ? AppColors.errorText
                  : AppColors.accent,
              onTap: () async {
                if (_busy) return;
                _busy = true;
                try {
                  final routeContext = Navigator.of(context).context;
                  _closeDrawer(context);
                  if (isLoggedIn) {
                    await signOut(routeContext);
                  } else {
                    await ensureLoggedIn(routeContext);
                  }
                } finally {
                  _busy = false;
                }
              },
            ),
            const SizedBox(height: AppSpacing.base),
          ],
        ),
      ),
    );
  }
}
