import '../../imports/imports.dart';

/// Displays an empty state with an icon, title, optional subtitle, and action.
///
/// Usage:
/// ```dart
/// AppEmptyState(
///   icon: Icons.inbox_outlined,
///   title: 'No messages yet',
///   subtitle: 'Your inbox will appear here.',
///   actionLabel: 'Refresh',
///   onAction: _refresh,
/// )
/// ```
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.08),
                borderRadius: AppBorders.xl,
              ),
              child: Icon(icon, size: 32, color: cs.primary.withValues(alpha: 0.85)),
            ),
            SizedBox(height: AppSpacing.lg.h),
            Text(
              title,
              style: tt.titleMedium?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              SizedBox(height: AppSpacing.sm.h),
              Text(
                subtitle!,
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: AppSpacing.lg.h),
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
