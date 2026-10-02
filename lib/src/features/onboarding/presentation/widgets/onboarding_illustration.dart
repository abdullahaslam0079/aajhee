import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';
import 'package:easy_localization/easy_localization.dart';

part 'onboarding_illustration_ui/onboarding_illustration_controller.dart';
part 'onboarding_illustration_ui/onboarding_illustration_view.dart';
part 'onboarding_illustration_ui/onboarding_illustration_type.dart';
part 'onboarding_illustration_ui/map_grid_painter.dart';
part 'onboarding_illustration_ui/glow_orb.dart';
part 'onboarding_illustration_ui/local_shops_scene.dart';
part 'onboarding_illustration_ui/same_day_delivery_scene.dart';
part 'onboarding_illustration_ui/order_pay_on_delivery_scene.dart';
part 'onboarding_illustration_ui/floating_badge.dart';
part 'onboarding_illustration_ui/deal_chip.dart';
part 'onboarding_illustration_ui/map_pin.dart';

class OnboardingIllustration extends StatefulWidget {
  const OnboardingIllustration({
    super.key,
    required this.type,
    required this.accentColor,
    required this.secondaryColor,
    this.animate = true,
  });

  final OnboardingIllustrationType type;
  final Color accentColor;
  final Color secondaryColor;
  final bool animate;

  @override
  State<OnboardingIllustration> createState() => _OnboardingIllustrationState();
}
