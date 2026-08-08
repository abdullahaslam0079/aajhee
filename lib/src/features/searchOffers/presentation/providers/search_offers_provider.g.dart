// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_offers_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SearchOffers)
final searchOffersProvider = SearchOffersProvider._();

final class SearchOffersProvider
    extends $NotifierProvider<SearchOffers, SearchOffersState> {
  SearchOffersProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'searchOffersProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$searchOffersHash();

  @$internal
  @override
  SearchOffers create() => SearchOffers();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchOffersState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchOffersState>(value),
    );
  }
}

String _$searchOffersHash() => r'eb04b55a4277329fdb0ddffeaebdf5ec86a36d89';

abstract class _$SearchOffers extends $Notifier<SearchOffersState> {
  SearchOffersState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SearchOffersState, SearchOffersState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SearchOffersState, SearchOffersState>,
        SearchOffersState,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
