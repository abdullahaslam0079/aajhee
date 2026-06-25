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
          borderRadius: AppBorders.full,
          color: _selected
              ? colorScheme.primary
              : colorScheme.surfaceContainerLowest,
          border: Border.all(
            color: _selected
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.35),
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
              : AppShadows.subtle,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppBorders.full,
            splashColor: colorScheme.primary.withValues(alpha: 0.12),
            highlightColor: colorScheme.primary.withValues(alpha: 0.06),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md.w,
                vertical: AppSpacing.sm.h,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: _selected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(width: AppSpacing.xs.w),
                  Text(
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
