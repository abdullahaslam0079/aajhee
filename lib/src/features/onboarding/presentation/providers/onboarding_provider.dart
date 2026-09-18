import 'package:aajhee/src/imports/packages_imports.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_provider.g.dart';

class OnboardingRepository {
  static const _storageKey = 'onboarding_completed';

  Future<bool> isCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_storageKey) ?? false;
  }

  Future<void> markCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_storageKey, true);
  }
}

@Riverpod(keepAlive: true)
OnboardingRepository onboardingRepository(Ref ref) {
  return OnboardingRepository();
}

@Riverpod(keepAlive: true)
Future<bool> onboardingCompleted(Ref ref) {
  return ref.watch(onboardingRepositoryProvider).isCompleted();
}
