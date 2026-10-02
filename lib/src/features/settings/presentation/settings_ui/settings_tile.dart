part of 'package:aajhee/src/features/settings/presentation/settings.dart';

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showChevron = true,
    this.titleColor,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    final tt = context.theme.textTheme;
    final cs = context.theme.colorScheme;
    final effectiveTitleColor = titleColor ?? cs.onSurface;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 14.w,
          vertical: AppSpacing.ms.h,
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: AppBorders.md,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            SizedBox(width: AppSpacing.ms.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: tt.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: effectiveTitleColor,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: AppSpacing.xxs.h),
                    Text(
                      subtitle!,
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
            if (trailing == null && showChevron)
              Icon(
                Icons.chevron_right_rounded,
                color: cs.outline,
                size: 26,
              ),
          ],
        ),
      ),
    );
  }
}
