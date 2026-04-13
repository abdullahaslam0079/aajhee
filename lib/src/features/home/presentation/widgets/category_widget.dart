import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';

class CategoryWidget extends StatelessWidget {
  final int selectedCategoryIndex;
  final int index;
  final String label;
  final VoidCallback onTap;

  const CategoryWidget({
    super.key,
    required this.selectedCategoryIndex,
    required this.index,
    required this.label,
    required this.onTap,
  });

  bool get _selected => selectedCategoryIndex == index;

  static const Duration _animationDuration = Duration(milliseconds: 220);

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final textTheme = context.theme.textTheme;

    return Padding(
      padding: EdgeInsets.only(right: AppSpacing.sm.w),
      child: AnimatedContainer(
        duration: _animationDuration,
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: AppBorders.sm,
          color: _selected
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest,
          border: Border.all(
            color: _selected ? colorScheme.primary : colorScheme.outlineVariant,
            width: 1,
          ),
          boxShadow: _selected
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.22),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppBorders.sm,
            splashColor: colorScheme.primary.withValues(alpha: 0.12),
            highlightColor: colorScheme.primary.withValues(alpha: 0.06),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md.w,
                vertical: AppSpacing.sm.h,
              ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: _selected ? FontWeight.w600 : FontWeight.w500,
                  letterSpacing: 0.15,
                  color: _selected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
