// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discounts_provider.dart';

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

@ProviderFor(DiscountsFeed)
final discountsFeedProvider = DiscountsFeedProvider._();

final class DiscountsFeedProvider
    extends $NotifierProvider<DiscountsFeed, DiscountsState> {
  DiscountsFeedProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'discountsFeedProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$discountsFeedHash();

  @$internal
  @override
  DiscountsFeed create() => DiscountsFeed();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DiscountsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DiscountsState>(value),
    );
  }
}

String _$discountsFeedHash() => r'c55a04a264a569e0dcea1436931273a2470a5785';

abstract class _$DiscountsFeed extends $Notifier<DiscountsState> {
  DiscountsState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DiscountsState, DiscountsState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<DiscountsState, DiscountsState>,
        DiscountsState,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
