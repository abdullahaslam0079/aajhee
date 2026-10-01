import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';

class CategoryWidget extends StatelessWidget {
  final int selectedCategoryIndex;
  final int index;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  /// Slightly smaller tile for subcategory rows.
  final bool compact;

  const CategoryWidget({
    super.key,
    required this.selectedCategoryIndex,
    required this.index,
    required this.label,
    required this.icon,
    required this.onTap,
    this.compact = false,
  });

  bool get _selected => selectedCategoryIndex == index;

  static const Duration _animationDuration = Duration(milliseconds: 180);

  /// Preferred row height for a non-compact category rail.
  static double get rowHeight => 78.h;

  /// Preferred row height for a compact (subcategory) rail.
  static double get compactRowHeight => 70.h;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final textTheme = context.theme.textTheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    final iconBoxSize = compact ? 42.w : 52.w;
    final iconSize = compact ? 18.sp : 22.sp;
    final tileWidth = compact ? 68.w : 76.w;

    final iconBg = _selected
        ? colorScheme.primary
        : isDark
            ? colorScheme.surfaceContainerHigh
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.85);
    final iconFg = _selected
        ? colorScheme.onPrimary
        : colorScheme.onSurface.withValues(alpha: 0.72);
    final labelColor = _selected
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;

    return Padding(
      padding: EdgeInsets.only(right: 10.w),
      child: SizedBox(
        width: tileWidth,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppBorders.lg,
            splashColor: colorScheme.primary.withValues(alpha: 0.1),
            highlightColor: colorScheme.primary.withValues(alpha: 0.05),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: _animationDuration,
                  curve: Curves.easeOutCubic,
                  width: iconBoxSize,
                  height: iconBoxSize,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: AppBorders.lg,
                  ),
                  child: Icon(icon, size: iconSize, color: iconFg),
                ),
                SizedBox(height: 6.h),
                AnimatedDefaultTextStyle(
                  duration: _animationDuration,
                  curve: Curves.easeOutCubic,
                  style: (textTheme.labelSmall ?? const TextStyle()).copyWith(
                    fontWeight: _selected ? FontWeight.w700 : FontWeight.w500,
                    letterSpacing: -0.1,
                    height: 1.1,
                    fontSize: compact ? 9.sp : 10.sp,
                    color: labelColor,
                  ),
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 3.h),
                AnimatedContainer(
                  duration: _animationDuration,
                  curve: Curves.easeOutCubic,
                  width: _selected ? 18.w : 0,
                  height: 2.5,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: AppBorders.full,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
