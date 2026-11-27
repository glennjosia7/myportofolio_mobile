import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/theme/app_tokens.dart';

/// Empty-list placeholder card aligned with the website dark slate surfaces.
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    required this.icon,
    required this.title,
    required this.subtitle,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Center(
    child: _StateCard(
      icon: icon,
      iconColor: AppColors.accent,
      iconBackground: AppColors.surfaceElevated,
      iconBorderColor: AppColors.line,
      borderColor: AppColors.line,
      title: title,
      message: subtitle,
    ),
  );
}

/// Retryable error card used when public portfolio fetches fail.
class ErrorStateView extends StatelessWidget {
  const ErrorStateView({
    required this.message,
    required this.onRetry,
    this.title = 'Gagal memuat data',
    super.key,
  });

  final String message;
  final VoidCallback onRetry;
  final String title;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: _StateCard(
        icon: Icons.error_outline,
        iconColor: AppColors.errorText,
        iconBackground: AppColors.danger.withValues(alpha: 0.2),
        borderColor: AppColors.danger.withValues(alpha: 0.75),
        title: title,
        message: message,
        action: FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('Coba lagi'),
        ),
      ),
    ),
  );
}

class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.borderColor,
    required this.title,
    required this.message,
    this.iconBorderColor,
    this.action,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final Color? iconBorderColor;
  final Color borderColor;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: AppLayout.maxLoginWidth),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(color: borderColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox.square(
                dimension: 48,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: iconBackground,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: iconBorderColor == null
                        ? null
                        : Border.all(color: iconBorderColor!),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
              ),
              const SizedBox(height: AppSpacing.base),
              Text(
                title,
                style: textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                message,
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              if (action != null) ...[
                const SizedBox(height: AppSpacing.base),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
