part of 'package:aajhee/src/features/commerce/presentation/screens/store_catalog_screen.dart';

class _StoreSegmentTabs extends StatelessWidget {
  const _StoreSegmentTabs({
    required this.selectedIndex,
    required this.onSelected,
    required this.productCount,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final int productCount;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final tabs = [
      productCount > 0 ? 'Products ($productCount)' : 'Products',
      'About',
    ];

    return Row(
      children: [
        for (var i = 0; i < tabs.length; i++)
          Expanded(
            child: InkWell(
              onTap: () => onSelected(i),
              borderRadius: AppBorders.sm,
              child: Padding(
                padding: EdgeInsets.only(bottom: 2.h),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      child: Text(
                        tabs[i],
                        textAlign: TextAlign.center,
                        style: tt.titleSmall?.copyWith(
                          fontWeight: selectedIndex == i
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: selectedIndex == i
                              ? cs.primary
                              : cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      height: 2.5,
                      width: selectedIndex == i ? 48.w : 0,
                      decoration: BoxDecoration(
                        color: cs.primary,
                        borderRadius: AppBorders.full,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
