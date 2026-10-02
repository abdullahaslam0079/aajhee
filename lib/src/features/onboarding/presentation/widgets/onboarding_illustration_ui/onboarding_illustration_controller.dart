part of 'package:aajhee/src/features/onboarding/presentation/widgets/onboarding_illustration.dart';

mixin OnboardingIllustrationController
    on
        SingleTickerProviderStateMixin<OnboardingIllustration>,
        State<OnboardingIllustration> {
  late final AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    if (widget.animate) {
      _floatController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }
}
