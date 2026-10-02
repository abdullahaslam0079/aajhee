part of 'package:aajhee/src/features/onboarding/presentation/screens/onboarding_page.dart';

class _OnboardingPageState extends ConsumerState<OnboardingPage>
    with OnboardingPageController {
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final slide = OnboardingPageController._slides[_currentIndex];

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  slide.backgroundTint.withValues(alpha: 0.08),
                  colorScheme.surfaceContainerLowest,
                  colorScheme.surfaceContainerLowest,
                ],
                stops: const [0, 0.45, 1],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.lg.w,
                    AppSpacing.sm.h,
                    AppSpacing.lg.w,
                    0,
                  ),
                  child: Row(
                    children: [
                      _AajheeWordmark(
                          textTheme: textTheme, colorScheme: colorScheme),
                      const Spacer(),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: !_isLastPage
                            ? TextButton(
                                key: const ValueKey('skip'),
                                onPressed: _onSkip,
                                style: TextButton.styleFrom(
                                  foregroundColor: colorScheme.onSurfaceVariant,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppSpacing.ms.w,
                                    vertical: AppSpacing.xs.h,
                                  ),
                                ),
                                child: Text(
                                  'onboarding.skip'.tr(),
                                  style: textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            : SizedBox(
                                key: const ValueKey('skip-spacer'),
                                width: 64.w),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: OnboardingPageController._slides.length,
                    onPageChanged: (index) =>
                        setState(() => _currentIndex = index),
                    itemBuilder: (context, index) {
                      return _OnboardingSlideView(
                        slide: OnboardingPageController._slides[index],
                        pageIndex: index,
                        pageController: _pageController,
                        textTheme: textTheme,
                        colorScheme: colorScheme,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.xl.w,
                    AppSpacing.md.h,
                    AppSpacing.xl.w,
                    AppSpacing.lg.h,
                  ),
                  child: Column(
                    children: [
                      Text(
                        'onboarding.step'.tr(namedArgs: {
                          'current': '${_currentIndex + 1}',
                          'total': '${OnboardingPageController._slides.length}',
                        }),
                        style: textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.7),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                      SizedBox(height: AppSpacing.sm.h),
                      _PageIndicator(
                        count: OnboardingPageController._slides.length,
                        currentIndex: _currentIndex,
                        activeColor: slide.accentColor,
                        inactiveColor:
                            colorScheme.outline.withValues(alpha: 0.3),
                        onDotTap: _goToPage,
                      ),
                      SizedBox(height: AppSpacing.xl.h),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 240),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.08),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: AppButton(
                          key: ValueKey(_isLastPage),
                          label: _isLastPage
                              ? 'shared.get_started'.tr()
                              : 'onboarding.next'.tr(),
                          onPressed: _onPrimaryAction,
                          variant: ButtonVariant.primary,
                          isFullWidth: true,
                          height: ButtonSize.large,
                          suffixIcon: _isLastPage
                              ? null
                              : Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 18.sp,
                                  color: colorScheme.onPrimary,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
