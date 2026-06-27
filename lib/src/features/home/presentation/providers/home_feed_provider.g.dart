// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_feed_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(discoveryService)
final discoveryServiceProvider = DiscoveryServiceProvider._();

final class DiscoveryServiceProvider extends $FunctionalProvider<
    DiscoveryService,
    DiscoveryService,
    DiscoveryService> with $Provider<DiscoveryService> {
  DiscoveryServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'discoveryServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$discoveryServiceHash();

  @$internal
  @override
  $ProviderElement<DiscoveryService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DiscoveryService create(Ref ref) {
    return discoveryService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DiscoveryService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DiscoveryService>(value),
    );
  }
}

String _$discoveryServiceHash() => r'6d094e22f34c1112880a16b089575780443e02a6';

@ProviderFor(HomeFeed)
final homeFeedProvider = HomeFeedProvider._();

final class HomeFeedProvider
    extends $NotifierProvider<HomeFeed, HomeFeedState> {
  HomeFeedProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'homeFeedProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$homeFeedHash();

  @$internal
  @override
  HomeFeed create() => HomeFeed();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeFeedState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeFeedState>(value),
    );
  }
}

String _$homeFeedHash() => r'c864e1a03fcc11731064e751a9f438e16780944f';

abstract class _$HomeFeed extends $Notifier<HomeFeedState> {
  HomeFeedState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<HomeFeedState, HomeFeedState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<HomeFeedState, HomeFeedState>,
        HomeFeedState,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
