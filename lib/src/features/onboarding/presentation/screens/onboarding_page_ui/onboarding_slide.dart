part of 'package:aajhee/src/features/onboarding/presentation/screens/onboarding_page.dart';

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
