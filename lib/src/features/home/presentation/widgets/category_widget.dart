import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';

class CategoryWidget extends StatelessWidget {
  final int selectedCategoryIndex;
  final int index;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const CategoryWidget({
    super.key,
    required this.selectedCategoryIndex,
    required this.index,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  bool get _selected => selectedCategoryIndex == index;

  static const Duration _animationDuration = Duration(milliseconds: 180);

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final textTheme = context.theme.textTheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    final bg = _selected
        ? colorScheme.primary
        : isDark
            ? colorScheme.surfaceContainerHigh
            : colorScheme.onSurface.withValues(alpha: 0.05);
    final fg = _selected
        ? colorScheme.onPrimary
        : isDark
            ? colorScheme.onSurfaceVariant
            : colorScheme.onSurface.withValues(alpha: 0.68);

    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: AnimatedContainer(
        duration: _animationDuration,
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: AppBorders.md,
          color: bg,
          border: !_selected && isDark
              ? Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.32),
                )
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppBorders.md,
            splashColor: colorScheme.primary.withValues(alpha: 0.1),
            highlightColor: colorScheme.primary.withValues(alpha: 0.05),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 14.sp, color: fg),
                    SizedBox(width: 5.w),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelMedium?.copyWith(
                        fontWeight:
                            _selected ? FontWeight.w600 : FontWeight.w500,
                        letterSpacing: 0,
                        height: 1.1,
                        color: fg,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
