part of 'package:aajhee/src/features/commerce/presentation/screens/product_search_screen.dart';

class _SearchLoadingBody extends StatelessWidget {
  const _SearchLoadingBody();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Skeletonizer(
      enabled: true,
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
        itemCount: 6,
        separatorBuilder: (_, __) => SizedBox(height: 10.h),
        itemBuilder: (context, index) {
          return Material(
            color: cs.surfaceContainerLowest,
            borderRadius: AppBorders.card,
            child: Padding(
              padding: EdgeInsets.all(10.r),
              child: Row(
                children: [
                  Container(
                    width: 64.w,
                    height: 64.w,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: AppBorders.md,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Loading product name placeholder',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Rs 0,000',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
