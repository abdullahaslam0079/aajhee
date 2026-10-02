// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(userProfileService)
final userProfileServiceProvider = UserProfileServiceProvider._();

final class UserProfileServiceProvider extends $FunctionalProvider<
    UserProfileService,
    UserProfileService,
    UserProfileService> with $Provider<UserProfileService> {
  UserProfileServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'userProfileServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userProfileServiceHash();

  @$internal
  @override
  $ProviderElement<UserProfileService> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UserProfileService create(Ref ref) {
    return userProfileService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserProfileService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserProfileService>(value),
    );
  }
}

String _$userProfileServiceHash() =>
    r'a06feae709dd812d548036a2a3759ce78d333578';

@ProviderFor(UserProfile)
final userProfileProvider = UserProfileProvider._();

final class UserProfileProvider
    extends $NotifierProvider<UserProfile, UserProfileState> {
  UserProfileProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'userProfileProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userProfileHash();

  @$internal
  @override
  UserProfile create() => UserProfile();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserProfileState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserProfileState>(value),
    );
  }
}

String _$userProfileHash() => r'd0a99454c5e98cecd6624e6a7c8e47caf938f0ff';

abstract class _$UserProfile extends $Notifier<UserProfileState> {
  UserProfileState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<UserProfileState, UserProfileState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<UserProfileState, UserProfileState>,
        UserProfileState,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
