part of 'package:aajhee/src/features/home/presentation/screens/stores_tab_screen.dart';

class _StoresCategoriesHeader extends StatelessWidget {
  const _StoresCategoriesHeader({
    required this.selectedCategoryIndex,
    required this.categoryLabels,
    required this.subcategories,
    required this.selectedSubcategoryId,
    required this.onCategoryTap,
    required this.onSubcategoryTap,
    required this.textTheme,
    required this.backgroundColor,
  });

  final int selectedCategoryIndex;
  final List<String> categoryLabels;
  final List<CategoryModel> subcategories;
  final int? selectedSubcategoryId;
  final ValueChanged<int> onCategoryTap;
  final ValueChanged<int?> onSubcategoryTap;
  final TextTheme textTheme;
  final Color backgroundColor;

  static const double _verticalPad = 2;

  @override
  Widget build(BuildContext context) {
    final pad = _verticalPad.h.ceilToDouble();
    final mainHeight = CategoryWidget.rowHeight.ceilToDouble();
    final subHeight = CategoryWidget.compactRowHeight.ceilToDouble();
    final rows = subcategories.isEmpty ? 1 : 2;
    final extent = (pad + mainHeight + (rows > 1 ? 4.h + subHeight : 0) + pad)
        .ceilToDouble();

    return SizedBox(
      height: extent,
      child: DecoratedBox(
        decoration: BoxDecoration(color: backgroundColor),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: pad),
          child: Column(
            children: [
              SizedBox(
                height: mainHeight,
                child: Stack(
                  children: [
                    ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding:
                          EdgeInsets.symmetric(horizontal: AppSpacing.ms.w),
                      itemCount: categoryLabels.length,
                      itemBuilder: (context, index) {
                        final label = categoryLabels[index];
                        return CategoryWidget(
                          label: label,
                          icon: index == 0
                              ? Icons.grid_view_rounded
                              : categoryIconForName(label),
                          onTap: () => onCategoryTap(index),
                          selectedCategoryIndex: selectedCategoryIndex,
                          index: index,
                        );
                      },
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      width: AppSpacing.ms.w + 12,
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                backgroundColor.withValues(alpha: 0),
                                backgroundColor,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (subcategories.isNotEmpty) ...[
                SizedBox(height: 4.h),
                SizedBox(
                  height: subHeight,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.ms.w),
                    itemCount: subcategories.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return CategoryWidget(
                          compact: true,
                          label: 'All',
                          icon: Icons.grid_view_rounded,
                          onTap: () => onSubcategoryTap(null),
                          selectedCategoryIndex:
                              selectedSubcategoryId == null ? 0 : -1,
                          index: 0,
                        );
                      }
                      final sub = subcategories[index - 1];
                      final selected = selectedSubcategoryId == sub.id;
                      return CategoryWidget(
                        compact: true,
                        label: sub.name,
                        icon: categoryIconForName(sub.name),
                        onTap: () => onSubcategoryTap(sub.id),
                        selectedCategoryIndex: selected ? index : -1,
                        index: index,
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
