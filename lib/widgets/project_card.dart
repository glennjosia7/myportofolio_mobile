import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/theme/app_tokens.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';

class ItemHomepage {
  final String name;
  final IconData icon;
  final Color color;

  final Widget? destination;
  final bool requiresLogin;
  final Future<void> Function(BuildContext)? onPressed;

  const ItemHomepage(
    this.name,
    this.icon,
    this.color, {
    this.destination,
    this.requiresLogin = false,
    this.onPressed,
  });
}

class ItemCard extends StatefulWidget {
  final ItemHomepage item;

  const ItemCard(this.item, {super.key});

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  bool _busy = false;

  Future<void> _handleTap() async {
    if (_busy) return;
    _busy = true;
    try {
      final item = widget.item;
      final action = item.onPressed;
      if (action != null) {
        await action(context);
        return;
      }
      if (item.requiresLogin && !await ensureLoggedIn(context)) return;
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Kamu telah menekan tombol ${item.name}!')),
        );

      final destination = item.destination;
      if (destination != null) {
        await Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => destination),
        );
      }
    } finally {
      _busy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final badgeForeground = item.color.computeLuminance() > 0.3
        ? AppColors.paper
        : AppColors.ink;
    final borderColor = item.color == AppColors.danger
        ? AppColors.danger.withValues(alpha: 0.75)
        : AppColors.line;

    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: borderColor),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        splashColor: AppColors.accent.withValues(alpha: 0.16),
        hoverColor: AppColors.surfaceElevated,
        onTap: _handleTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: item.color,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: SizedBox(
                  width: 38,
                  height: 38,
                  child: Center(
                    child: Icon(item.icon, color: badgeForeground, size: 22),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                item.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
