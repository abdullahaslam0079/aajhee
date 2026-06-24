import 'package:goluto/src/imports/packages_imports.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'favorite_stores_provider.g.dart';

class FavoriteStoresState {
  const FavoriteStoresState({
    this.favoriteIds = const {},
    this.isLoading = false,
  });

  final Set<String> favoriteIds;
  final bool isLoading;

  FavoriteStoresState copyWith({
    Set<String>? favoriteIds,
    bool? isLoading,
  }) {
    return FavoriteStoresState(
      favoriteIds: favoriteIds ?? this.favoriteIds,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool isFavorite(String storeId) => favoriteIds.contains(storeId);
}

@Riverpod(keepAlive: true)
class FavoriteStores extends _$FavoriteStores {
  static const _storageKey = 'favorite_store_ids';

  SharedPreferences? _prefs;
  late final Future<void> _initialLoad;

  @override
  FavoriteStoresState build() {
    _initialLoad = _load();
    return const FavoriteStoresState(isLoading: true);
  }

  Future<void> ensureLoaded() => _initialLoad;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> _load() async {
    try {
      final prefs = await _preferences;
      final ids = prefs.getStringList(_storageKey) ?? const [];
      state = FavoriteStoresState(favoriteIds: ids.toSet());
    } catch (_) {
      state = const FavoriteStoresState();
    }
  }

  Future<void> _persist(Set<String> favoriteIds) async {
    final prefs = await _preferences;
    await prefs.setStringList(_storageKey, favoriteIds.toList());
    state = FavoriteStoresState(favoriteIds: favoriteIds);
  }

  Future<void> toggle(String storeId) async {
    final updated = Set<String>.from(state.favoriteIds);
    if (updated.contains(storeId)) {
      updated.remove(storeId);
    } else {
      updated.add(storeId);
    }
    await _persist(updated);
  }
}
