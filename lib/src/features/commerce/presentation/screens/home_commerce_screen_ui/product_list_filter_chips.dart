part of 'package:aajhee/src/features/commerce/presentation/screens/home_commerce_screen.dart';

class _ProductListFilterChips extends StatelessWidget {
  const _ProductListFilterChips({
    required this.selected,
    required this.onSelected,
  });

  final ProductListFilter selected;
  final ValueChanged<ProductListFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: ProductListFilter.values.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final filter = ProductListFilter.values[index];
          final isSelected = filter == selected;
          final cs = context.theme.colorScheme;
          final tt = context.theme.textTheme;
          final isDark = cs.brightness == Brightness.dark;
          final bg = isSelected
              ? cs.primary
              : isDark
                  ? cs.surfaceContainerHigh
                  : cs.surfaceContainerLowest;
          final fg = isSelected ? cs.onPrimary : cs.onSurfaceVariant;
          final icon = switch (filter) {
            ProductListFilter.all => Icons.grid_view_rounded,
            ProductListFilter.sameDay => Icons.bolt_rounded,
            ProductListFilter.topRated => Icons.star_outline_rounded,
            ProductListFilter.priceLowToHigh => Icons.south_rounded,
          };

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onSelected(filter),
              borderRadius: AppBorders.md,
              child: Ink(
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: AppBorders.md,
                  border: isSelected
                      ? null
                      : Border.all(
                          color: isDark
                              ? cs.outline.withValues(alpha: 0.32)
                              : cs.outlineVariant,
                        ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 14.sp, color: fg),
                      SizedBox(width: 5.w),
                      Text(
                        filter.label,
                        style: tt.labelMedium?.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: fg,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
