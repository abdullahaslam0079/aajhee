// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_stores_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(favoritesService)
final favoritesServiceProvider = FavoritesServiceProvider._();

final class FavoritesServiceProvider extends $FunctionalProvider<
    FavoritesService,
    FavoritesService,
    FavoritesService> with $Provider<FavoritesService> {
  FavoritesServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'favoritesServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$favoritesServiceHash();

  @$internal
  @override
  $ProviderElement<FavoritesService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FavoritesService create(Ref ref) {
    return favoritesService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FavoritesService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FavoritesService>(value),
    );
  }
}

String _$favoritesServiceHash() => r'e770618e2c849e3c07522188ba9f3fb62508c041';

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

String _$favoriteStoresHash() => r'45fbdbd6769c60884cb4ce0a658eee6bb968ba21';

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
