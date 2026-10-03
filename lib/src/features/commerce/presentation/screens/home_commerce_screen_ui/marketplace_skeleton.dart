part of 'package:aajhee/src/features/commerce/presentation/screens/home_commerce_screen.dart';

class _MarketplaceSkeleton extends StatelessWidget {
  const _MarketplaceSkeleton({required this.bottomInset});

  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bone = cs.surfaceContainerHighest;

    Widget box({
      required double height,
      double? width,
      BorderRadius? radius,
    }) {
      return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: bone,
          borderRadius: radius ?? AppBorders.md,
        ),
      );
    }

    Widget sectionHeader() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            box(height: 16.h, width: 150.w),
            SizedBox(height: 6.h),
            box(height: 12.h, width: 200.w),
          ],
        );

    Widget productRow() => SizedBox(
          height: 168.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (_, __) => SizedBox(width: 10.w),
            itemBuilder: (_, __) => box(height: 168.h, width: 122.w),
          ),
        );

    Widget shopRow() => SizedBox(
          height: _ShopCarousel._cardHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (_, __) => SizedBox(width: 8.w),
            itemBuilder: (_, __) =>
                box(height: _ShopCarousel._cardHeight, width: 220.w),
          ),
        );

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.ms.w,
        AppSpacing.md.h,
        AppSpacing.ms.w,
        bottomInset,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionHeader(),
          SizedBox(height: AppSpacing.xs.h),
          productRow(),
          SizedBox(height: AppSpacing.md.h),
          sectionHeader(),
          SizedBox(height: AppSpacing.xs.h),
          shopRow(),
          SizedBox(height: AppSpacing.md.h),
          sectionHeader(),
          SizedBox(height: AppSpacing.xs.h),
          SizedBox(
            height: 38.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              separatorBuilder: (_, __) => SizedBox(width: 8.w),
              itemBuilder: (_, __) =>
                  box(height: 38.h, width: 96.w, radius: AppBorders.full),
            ),
          ),
          SizedBox(height: 10.h),
          shopRow(),
        ],
      ),
    );
  }
}