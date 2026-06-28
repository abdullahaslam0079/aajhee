import 'package:goluto/src/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:goluto/src/features/onboarding/presentation/widgets/onboarding_illustration.dart';
import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.titleKey,
    required this.subtitleKey,
    required this.illustration,
    required this.accentColor,
    required this.secondaryColor,
    required this.backgroundTint,
  });

  final String titleKey;
  final String subtitleKey;
  final OnboardingIllustrationType illustration;
  final Color accentColor;
  final Color secondaryColor;
  final Color backgroundTint;
}

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  late final PageController _pageController;
  int _currentIndex = 0;

  static const _slides = [
    _OnboardingSlide(
      titleKey: 'onboarding.onboarding_title_1',
      subtitleKey: 'onboarding.onboarding_subtitle_1',
      illustration: OnboardingIllustrationType.discoverDeals,
      accentColor: Color(0xFF1F1F21),
      secondaryColor: Color(0xFF6366F1),
      backgroundTint: Color(0xFF6366F1),
    ),
    _OnboardingSlide(
      titleKey: 'onboarding.onboarding_title_2',
      subtitleKey: 'onboarding.onboarding_subtitle_2',
      illustration: OnboardingIllustrationType.exploreMap,
      accentColor: Color(0xFF0288D1),
      secondaryColor: Color(0xFF1F1F21),
      backgroundTint: Color(0xFF0288D1),
    ),
    _OnboardingSlide(
      titleKey: 'onboarding.onboarding_title_3',
      subtitleKey: 'onboarding.onboarding_subtitle_3',
      illustration: OnboardingIllustrationType.scanOffers,
      accentColor: Color(0xFF2E7D32),
      secondaryColor: Color(0xFF1F1F21),
      backgroundTint: Color(0xFF2E7D32),
    ),
  ];

  bool get _isLastPage => _currentIndex == _slides.length - 1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _onGetStarted() async {
    HapticFeedback.lightImpact();
    await ref.read(onboardingRepositoryProvider).markCompleted();
    ref.invalidate(onboardingCompletedProvider);
    if (!mounted) return;
    context.go(AppRoutes.login);
  }

  void _onPrimaryAction() {
    HapticFeedback.selectionClick();
    if (_isLastPage) {
      _onGetStarted();
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  void _onSkip() {
    _onGetStarted();
  }

  void _goToPage(int index) {
    if (index == _currentIndex) return;
    HapticFeedback.selectionClick();
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final slide = _slides[_currentIndex];

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
                      _GolutoWordmark(textTheme: textTheme, colorScheme: colorScheme),
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
                            : SizedBox(key: const ValueKey('skip-spacer'), width: 64.w),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _slides.length,
                    onPageChanged: (index) => setState(() => _currentIndex = index),
                    itemBuilder: (context, index) {
                      return _OnboardingSlideView(
                        slide: _slides[index],
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
                          'total': '${_slides.length}',
                        }),
                        style: textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                      SizedBox(height: AppSpacing.sm.h),
                      _PageIndicator(
                        count: _slides.length,
                        currentIndex: _currentIndex,
                        activeColor: slide.accentColor,
                        inactiveColor: colorScheme.outline.withValues(alpha: 0.3),
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

class _GolutoWordmark extends StatelessWidget {
  const _GolutoWordmark({
    required this.textTheme,
    required this.colorScheme,
  });

  final TextTheme textTheme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final style = textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w800,
      fontSize: 24.sp,
      letterSpacing: -0.5,
      fontFamily: AppFonts.primary,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Go', style: style?.copyWith(color: colorScheme.primary)),
        Text('luto', style: style?.copyWith(color: colorScheme.onSurface)),
      ],
    );
  }
}

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
