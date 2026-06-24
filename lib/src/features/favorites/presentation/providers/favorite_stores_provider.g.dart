// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_stores_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FavoriteStores)
final favoriteStoresProvider = FavoriteStoresProvider._();

final class FavoriteStoresProvider
    extends $NotifierProvider<FavoriteStores, FavoriteStoresState> {
  FavoriteStoresProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'favoriteStoresProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$favoriteStoresHash();

  @$internal
  @override
  FavoriteStores create() => FavoriteStores();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FavoriteStoresState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FavoriteStoresState>(value),
    );
  }
}

String _$favoriteStoresHash() => r'c218ac5ece48525689cb7184d571498006c6b59c';

abstract class _$FavoriteStores extends $Notifier<FavoriteStoresState> {
  FavoriteStoresState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<FavoriteStoresState, FavoriteStoresState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<FavoriteStoresState, FavoriteStoresState>,
        FavoriteStoresState,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
