import '../../imports/imports.dart';

/// Displays an error state with an icon, title, optional body, and retry button.
///
/// Usage:
/// ```dart
/// AppErrorWidget(
///   title: 'Something went wrong',
///   message: error.toString(),
///   onRetry: () => ref.invalidate(myProvider),
/// )
/// ```
class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({
    super.key,
    this.title = 'Something went wrong',
    this.message,
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
  });

  final String title;
  final String? message;
  final VoidCallback? onRetry;
  final IconData icon;

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
                color: cs.error.withValues(alpha: 0.08),
                borderRadius: AppBorders.xl,
              ),
              child: Icon(icon, size: 32, color: cs.error),
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
            if (message != null) ...[
              SizedBox(height: AppSpacing.sm.h),
              Text(
                message!,
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              SizedBox(height: AppSpacing.lg.h),
              AppButton(
                label: 'Try again',
                onPressed: onRetry,
                variant: ButtonVariant.outline,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
