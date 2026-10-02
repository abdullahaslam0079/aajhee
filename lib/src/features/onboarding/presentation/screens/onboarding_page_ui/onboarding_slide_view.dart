part of 'package:aajhee/src/features/onboarding/presentation/screens/onboarding_page.dart';

class _OnboardingSlideView extends StatelessWidget {
  const _OnboardingSlideView({
    required this.slide,
    required this.pageIndex,
    required this.pageController,
    required this.textTheme,
    required this.colorScheme,
  });

  final _OnboardingSlide slide;
  final int pageIndex;
  final PageController pageController;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pageController,
      builder: (context, child) {
        final page = pageController.hasClients
            ? (pageController.page ?? pageController.initialPage.toDouble())
            : pageController.initialPage.toDouble();
        final delta = (page - pageIndex).abs().clamp(0.0, 1.0);
        final opacity = 1 - (delta * 0.45);
        final slideOffset = (page - pageIndex) * 28.h;
        final scale = 1 - (delta * 0.06);

        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, slideOffset),
            child: Transform.scale(
              scale: scale,
              child: child,
            ),
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
        child: Column(
          children: [
            SizedBox(height: AppSpacing.lg.h),
            Expanded(
              flex: 5,
              child: Center(
                child: OnboardingIllustration(
                  type: slide.illustration,
                  accentColor: slide.accentColor,
                  secondaryColor: slide.secondaryColor,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    slide.titleKey.tr(),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                      height: 1.15,
                      fontSize: 28.sp,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: AppSpacing.md.h),
                  Text(
                    slide.subtitleKey.tr(),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.45,
                      fontSize: 15.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
