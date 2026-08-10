// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'top_picks_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(engagementService)
final engagementServiceProvider = EngagementServiceProvider._();

final class EngagementServiceProvider extends $FunctionalProvider<
    EngagementService,
    EngagementService,
    EngagementService> with $Provider<EngagementService> {
  EngagementServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'engagementServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$engagementServiceHash();

  @$internal
  @override
  $ProviderElement<EngagementService> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  EngagementService create(Ref ref) {
    return engagementService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EngagementService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EngagementService>(value),
    );
  }
}

String _$engagementServiceHash() => r'232fba8d549db9a7753a16e22333fc135d4afcd3';

@ProviderFor(TopPicksFeed)
final topPicksFeedProvider = TopPicksFeedProvider._();

final class TopPicksFeedProvider
    extends $NotifierProvider<TopPicksFeed, TopPicksState> {
  TopPicksFeedProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'topPicksFeedProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$topPicksFeedHash();

  @$internal
  @override
  TopPicksFeed create() => TopPicksFeed();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TopPicksState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TopPicksState>(value),
    );
  }
}

String _$topPicksFeedHash() => r'fe566fa1cbe8977c6dd4a3160d21b4a46f8b876b';

abstract class _$TopPicksFeed extends $Notifier<TopPicksState> {
  TopPicksState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<TopPicksState, TopPicksState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<TopPicksState, TopPicksState>,
        TopPicksState,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
