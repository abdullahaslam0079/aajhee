part of 'package:aajhee/src/features/home/presentation/screens/stores_tab_screen.dart';

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.textTheme,
    required this.colorScheme,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? colorScheme.primaryContainer.withValues(alpha: 0.85)
          : Colors.transparent,
      borderRadius: AppBorders.full,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorders.full,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: selected
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.45),
              ),
              SizedBox(width: 3.w),
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 11.sp,
                  color: selected
                      ? colorScheme.primary
                      : colorScheme.onSurface.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
