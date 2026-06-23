import 'package:goluto/src/imports/packages_imports.dart';

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

final onboardingRepositoryProvider = Provider<OnboardingRepository>(
  (ref) => OnboardingRepository(),
);

final onboardingCompletedProvider = FutureProvider<bool>((ref) {
  return ref.read(onboardingRepositoryProvider).isCompleted();
});
