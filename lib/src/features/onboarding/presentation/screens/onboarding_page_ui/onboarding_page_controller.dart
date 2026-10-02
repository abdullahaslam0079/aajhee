part of 'package:aajhee/src/features/onboarding/presentation/screens/onboarding_page.dart';

mixin OnboardingPageController on ConsumerState<OnboardingPage> {
  late final PageController _pageController;
  int _currentIndex = 0;

  static const _slides = [
    _OnboardingSlide(
      titleKey: 'onboarding.onboarding_title_1',
      subtitleKey: 'onboarding.onboarding_subtitle_1',
      illustration: OnboardingIllustrationType.localShops,
      accentColor: AppBrandColors.lightPrimary,
      secondaryColor: AppBrandColors.lightSecondary,
      backgroundTint: AppBrandColors.lightPrimary,
    ),
    _OnboardingSlide(
      titleKey: 'onboarding.onboarding_title_2',
      subtitleKey: 'onboarding.onboarding_subtitle_2',
      illustration: OnboardingIllustrationType.sameDayDelivery,
      accentColor: AppBrandColors.lightSecondary,
      secondaryColor: AppBrandColors.lightPrimary,
      backgroundTint: AppBrandColors.lightSecondary,
    ),
    _OnboardingSlide(
      titleKey: 'onboarding.onboarding_title_3',
      subtitleKey: 'onboarding.onboarding_subtitle_3',
      illustration: OnboardingIllustrationType.orderPayOnDelivery,
      accentColor: AppBrandColors.lightPrimary,
      secondaryColor: AppBrandColors.lightDeal,
      backgroundTint: AppBrandColors.lightPrimary,
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
}
