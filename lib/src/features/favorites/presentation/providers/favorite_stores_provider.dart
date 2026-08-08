import 'dart:async';

import 'package:goluto/src/features/auth/presentation/providers/session_provider.dart';
import 'package:goluto/src/features/discounts/data/services/engagement_service.dart';
import 'package:goluto/src/imports/packages_imports.dart';
import 'package:goluto/src/utils/logger.dart';
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

  Future<void> toggle(String storeId, {int? businessId}) async {
    final updated = Set<String>.from(state.favoriteIds);
    final nowFavorite = !updated.contains(storeId);
    if (nowFavorite) {
      updated.add(storeId);
    } else {
      updated.remove(storeId);
    }
    await _persist(updated);

    if (businessId != null) {
      unawaited(_syncBusinessLike(businessId, liked: nowFavorite));
    }
  }

  Future<void> _syncBusinessLike(int businessId, {required bool liked}) async {
    final session = ref.read(sessionProvider);
    if (session.status != SessionStatus.authenticated) return;

    final result = await EngagementService.instance.setBusinessLike(
      businessId,
      liked: liked,
    );
    result.fold(
      (failure) => AppLogger.warning(
        'Failed to sync business favorite: ${failure.message}',
      ),
      (_) {},
    );
  }
}
