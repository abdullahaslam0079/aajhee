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

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.ms.w,
        AppSpacing.sm.h,
        AppSpacing.ms.w,
        bottomInset,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 34.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              separatorBuilder: (_, __) => SizedBox(width: 8.w),
              itemBuilder: (_, __) => box(height: 34.h, width: 78.w),
            ),
          ),
          SizedBox(height: AppSpacing.xs.h),
          box(height: 16.h, width: 120.w),
          SizedBox(height: AppSpacing.xs.h),
          SizedBox(
            height: 168.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (_, __) => SizedBox(width: 10.w),
              itemBuilder: (_, __) => box(height: 168.h, width: 126.w),
            ),
          ),
          SizedBox(height: AppSpacing.sm.h),
          box(height: 16.h, width: 140.w),
          SizedBox(height: AppSpacing.xs.h),
          SizedBox(
            height: 72.w + 16.w,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (_, __) => SizedBox(width: 10.w),
              itemBuilder: (_, __) => box(height: 72.w + 16.w, width: 252.w),
            ),
          ),
          SizedBox(height: AppSpacing.md.h),
          box(height: 16.h, width: 110.w),
          SizedBox(height: AppSpacing.xs.h),
          Row(
            children: [
              Expanded(child: box(height: 180.h)),
              SizedBox(width: 10.w),
              Expanded(child: box(height: 180.h)),
            ],
          ),
        ],
      ),
    );
  }
}
