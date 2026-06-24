// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(authStateStream)
final authStateStreamProvider = AuthStateStreamProvider._();

final class AuthStateStreamProvider extends $FunctionalProvider<
        AsyncValue<AppUser?>, AppUser?, Stream<AppUser?>>
    with $FutureModifier<AppUser?>, $StreamProvider<AppUser?> {
  AuthStateStreamProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'authStateStreamProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$authStateStreamHash();

  @$internal
  @override
  $StreamProviderElement<AppUser?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<AppUser?> create(Ref ref) {
    return authStateStream(ref);
  }
}

String _$authStateStreamHash() => r'9e064747451107f7ac467d84e16d6cdac9449892';

@ProviderFor(Session)
final sessionProvider = SessionProvider._();

final class SessionProvider extends $NotifierProvider<Session, SessionState> {
  SessionProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'sessionProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$sessionHash();

  @$internal
  @override
  Session create() => Session();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionState>(value),
    );
  }
}

String _$sessionHash() => r'fb1c5a93e4e7af320848456162e38a61c427da9f';

abstract class _$Session extends $Notifier<SessionState> {
  SessionState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SessionState, SessionState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SessionState, SessionState>,
        SessionState,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
