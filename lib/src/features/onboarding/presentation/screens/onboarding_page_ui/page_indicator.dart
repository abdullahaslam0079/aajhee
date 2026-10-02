part of 'package:aajhee/src/features/onboarding/presentation/screens/onboarding_page.dart';

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({
    required this.count,
    required this.currentIndex,
    required this.activeColor,
    required this.inactiveColor,
    required this.onDotTap,
  });

  final int count;
  final int currentIndex;
  final Color activeColor;
  final Color inactiveColor;
  final ValueChanged<int> onDotTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == currentIndex;
        return GestureDetector(
          onTap: () => onDotTap(index),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 8.h),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              width: isActive ? 28.w : 8.w,
              height: 8.h,
              decoration: BoxDecoration(
                color: isActive ? activeColor : inactiveColor,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        );
      }),
    );
  }
}
