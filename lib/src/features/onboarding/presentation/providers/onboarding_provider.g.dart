// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(onboardingRepository)
final onboardingRepositoryProvider = OnboardingRepositoryProvider._();

final class OnboardingRepositoryProvider extends $FunctionalProvider<
    OnboardingRepository,
    OnboardingRepository,
    OnboardingRepository> with $Provider<OnboardingRepository> {
  OnboardingRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'onboardingRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$onboardingRepositoryHash();

  @$internal
  @override
  $ProviderElement<OnboardingRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OnboardingRepository create(Ref ref) {
    return onboardingRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OnboardingRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OnboardingRepository>(value),
    );
  }
}

String _$onboardingRepositoryHash() =>
    r'1c6f36b25b58ddda1212173ce49ee012247c79fc';

@ProviderFor(onboardingCompleted)
final onboardingCompletedProvider = OnboardingCompletedProvider._();

final class OnboardingCompletedProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  OnboardingCompletedProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'onboardingCompletedProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$onboardingCompletedHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return onboardingCompleted(ref);
  }
}

String _$onboardingCompletedHash() =>
    r'44b067280fddfb0fcd6dd2ac7bd970aff7d0fd4c';
