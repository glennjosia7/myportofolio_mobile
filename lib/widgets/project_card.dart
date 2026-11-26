import 'package:material_ui/material_ui.dart';
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
    return Material(
      color: item.color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _handleTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, color: Colors.white, size: 30.0),
                const Padding(padding: EdgeInsets.all(3)),
                Text(
                  item.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
