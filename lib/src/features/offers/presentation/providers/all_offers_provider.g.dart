// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'all_offers_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AllOffersFeed)
final allOffersFeedProvider = AllOffersFeedProvider._();

final class AllOffersFeedProvider
    extends $NotifierProvider<AllOffersFeed, AllOffersState> {
  AllOffersFeedProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'allOffersFeedProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$allOffersFeedHash();

  @$internal
  @override
  AllOffersFeed create() => AllOffersFeed();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AllOffersState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AllOffersState>(value),
    );
  }
}

String _$allOffersFeedHash() => r'282fe5b8af2b1d1f6ef9177ba77524bfd81aa979';

abstract class _$AllOffersFeed extends $Notifier<AllOffersState> {
  AllOffersState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AllOffersState, AllOffersState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AllOffersState, AllOffersState>,
        AllOffersState,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
