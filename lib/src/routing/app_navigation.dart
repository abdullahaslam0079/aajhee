import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:goluto/src/features/auth/presentation/providers/session_provider.dart';
import 'package:goluto/src/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:goluto/src/features/settings/presentation/providers/saved_addresses_provider.dart';
import 'package:goluto/src/routing/app_routes.dart';

void navigateAfterAuthentication(
  BuildContext context, {
  required bool hasSavedAddress,
}) {
  if (hasSavedAddress) {
    context.go(AppRoutes.bottomNavigator);
  } else {
    context.go('${AppRoutes.addAddress}?onboarding=true');
  }
}

bool hasSavedAddress(WidgetRef ref) {
  return ref.read(savedAddressesProvider).addresses.isNotEmpty;
}

bool hasSavedAddressFromContext(BuildContext context) {
  return ProviderScope.containerOf(context)
      .read(savedAddressesProvider)
      .addresses
      .isNotEmpty;
}

Future<void> _waitForSession(WidgetRef ref) async {
  while (ref.read(sessionProvider).status == SessionStatus.unknown) {
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
}

Future<void> navigateFromSplash(BuildContext context, WidgetRef ref) async {
  await Future.wait([
    ref.read(savedAddressesProvider.notifier).ensureLoaded(),
    ref.read(onboardingCompletedProvider.future),
    _waitForSession(ref),
  ]);

  if (!context.mounted) return;

  final onboardingComplete =
      ref.read(onboardingCompletedProvider).value ?? false;

  if (!onboardingComplete) {
    context.go(AppRoutes.onboarding);
    return;
  }

  final session = ref.read(sessionProvider);
  if (session.status != SessionStatus.authenticated) {
    context.go(AppRoutes.login);
    return;
  }

  final savedAddress =
      ref.read(savedAddressesProvider).addresses.isNotEmpty;
  if (savedAddress) {
    context.go(AppRoutes.bottomNavigator);
    return;
  }

  context.go('${AppRoutes.addAddress}?onboarding=true');
}
