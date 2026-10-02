import 'package:aajhee/src/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:aajhee/src/features/onboarding/presentation/widgets/onboarding_illustration.dart';
import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';
import 'package:aajhee/src/routing/app_routes.dart';
import 'package:easy_localization/easy_localization.dart';

part 'onboarding_page_ui/onboarding_page_controller.dart';
part 'onboarding_page_ui/onboarding_page_view.dart';
part 'onboarding_page_ui/onboarding_slide.dart';
part 'onboarding_page_ui/aajhee_wordmark.dart';
part 'onboarding_page_ui/onboarding_slide_view.dart';
part 'onboarding_page_ui/page_indicator.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}
