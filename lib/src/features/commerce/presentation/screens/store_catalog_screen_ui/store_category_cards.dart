part of 'package:aajhee/src/features/commerce/presentation/screens/store_catalog_screen.dart';

class _StoreCategoryCards extends StatelessWidget {
  const _StoreCategoryCards({
    required this.sections,
    required this.onSelected,
    this.selectedIndex,
  });

  final List<({String title, List<Map<String, dynamic>> items})> sections;
  final ValueChanged<int> onSelected;
  final int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SizedBox(
      height: 72.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: sections.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final section = sections[index];
          final selected = selectedIndex == index;
          final imageUrl = resolveMediaUrl(
            section.items.first['image_url']?.toString(),
          );

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onSelected(index),
              borderRadius: AppBorders.card,
              child: Ink(
                width: 168.w,
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLowest,
                  borderRadius: AppBorders.card,
                  border: Border.all(
                    color: selected
                        ? cs.primary
                        : cs.outlineVariant.withValues(alpha: 0.75),
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: AppBorders.full,
                      child: SizedBox(
                        width: 44.w,
                        height: 44.w,
                        child: imageUrl != null
                            ? CommonImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                              )
                            : ColoredBox(
                                color: cs.primary.withValues(alpha: 0.1),
                                child: Icon(
                                  categoryIconForName(section.title),
                                  size: 18,
                                  color: cs.primary,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            section.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: tt.labelLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: cs.onSurface,
                              height: 1.15,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            '${section.items.length} items',
                            style: tt.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: cs.onSurfaceVariant.withValues(alpha: 0.55),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StoreFilterChips extends StatelessWidget {
  const _StoreFilterChips({
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SizedBox(
      height: 32.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: labels.length,
        separatorBuilder: (_, __) => SizedBox(width: 6.w),
        itemBuilder: (context, index) {
          final selected = selectedIndex == index;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onSelected(index),
              borderRadius: AppBorders.full,
              child: Ink(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  color: selected
                      ? cs.primary
                      : cs.surfaceContainerLowest,
                  borderRadius: AppBorders.full,
                  border: selected
                      ? null
                      : Border.all(
                          color: cs.outlineVariant.withValues(alpha: 0.85),
                        ),
                ),
                child: Center(
                  child: Text(
                    labels[index],
                    style: tt.labelMedium?.copyWith(
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w600,
                      color: selected ? cs.onPrimary : cs.onSurface,
                      height: 1.1,
                    ),
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
