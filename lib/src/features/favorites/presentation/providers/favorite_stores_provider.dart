import 'dart:async';

import 'package:goluto/src/features/auth/presentation/providers/session_provider.dart';
import 'package:goluto/src/features/discounts/data/services/engagement_service.dart';
import 'package:goluto/src/features/home/data/models/map_branch_model.dart';
import 'package:goluto/src/features/settings/presentation/providers/saved_addresses_provider.dart';
import 'package:goluto/src/utils/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'favorite_stores_provider.g.dart';

class FavoriteStoresState {
  const FavoriteStoresState({
    this.favoriteBusinessIds = const {},
    this.branches = const [],
    this.page = 0,
    this.hasMore = false,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final Set<int> favoriteBusinessIds;
  final List<MapBranchModel> branches;
  final int page;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;

  FavoriteStoresState copyWith({
    Set<int>? favoriteBusinessIds,
    List<MapBranchModel>? branches,
    int? page,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FavoriteStoresState(
      favoriteBusinessIds: favoriteBusinessIds ?? this.favoriteBusinessIds,
      branches: branches ?? this.branches,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  bool isFavorite(int businessId) => favoriteBusinessIds.contains(businessId);
}

@Riverpod(keepAlive: true)
class FavoriteStores extends _$FavoriteStores {
  static const _pageSize = 20;

  Future<void> _loadFuture = Future.value();
  int _requestId = 0;

  @override
  FavoriteStoresState build() {
    ref.listen(sessionProvider, (previous, next) {
      if (next.status == SessionStatus.authenticated) {
        _scheduleRefresh();
      } else if (next.status == SessionStatus.unauthenticated) {
        state = const FavoriteStoresState();
      }
    });

    ref.listen(savedAddressesProvider, (previous, next) {
      if (next.isLoading) return;
      final session = ref.read(sessionProvider);
      if (session.status != SessionStatus.authenticated) return;
      if (previous?.selectedAddress?.id == next.selectedAddress?.id) return;
      _scheduleRefresh();
    });

    final session = ref.read(sessionProvider);
    if (session.status == SessionStatus.authenticated) {
      // Defer so we never touch `state` while the provider is still mounting.
      _scheduleRefresh();
      return const FavoriteStoresState(isLoading: true);
    }

    return const FavoriteStoresState();
  }

  Future<void> ensureLoaded() => _loadFuture;

  void _scheduleRefresh() {
    _loadFuture = Future.microtask(() async {
      if (!ref.mounted) return;
      await refresh();
    });
  }

  Future<void> refresh() => _fetch(reset: true);

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading || state.isLoadingMore) return;
    await _fetch(reset: false);
  }

  Future<void> _fetch({required bool reset}) async {
    final session = ref.read(sessionProvider);
    if (session.status != SessionStatus.authenticated) {
      if (ref.mounted) {
        state = const FavoriteStoresState();
      }
      return;
    }

    if (!ref.mounted) return;
    final requestId = ++_requestId;
    final nextPage = reset ? 1 : state.page + 1;

    state = state.copyWith(
      isLoading: reset,
      isLoadingMore: !reset,
      branches: reset ? const [] : state.branches,
      clearError: true,
    );

    try {
      await ref.read(savedAddressesProvider.notifier).ensureLoaded();
      if (!ref.mounted || requestId != _requestId) return;

      final addressId =
          ref.read(savedAddressesProvider).selectedAddress?.id.toString();
      final result = await EngagementService.instance.getFavoriteBranches(
        addressId: addressId,
        page: nextPage,
        pageSize: _pageSize,
      );
      if (!ref.mounted || requestId != _requestId) return;

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            isLoadingMore: false,
            errorMessage: failure.message,
          );
          AppLogger.warning(
            'Failed to load favorite stores: ${failure.message}',
          );
        },
        (page) {
          final branches = reset
              ? page.page.results
              : [...state.branches, ...page.page.results];
          state = state.copyWith(
            favoriteBusinessIds: page.likedBusinessIds,
            branches: branches,
            page: page.page.page,
            hasMore: page.hasMore,
            isLoading: false,
            isLoadingMore: false,
            clearError: true,
          );
        },
      );
    } catch (error, stackTrace) {
      AppLogger.error('Failed to load favorite stores', error, stackTrace);
      if (!ref.mounted || requestId != _requestId) return;
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        errorMessage: 'Failed to load favorites',
      );
    }
  }

  Future<void> toggle(
    int businessId, {
    MapBranchModel? branch,
  }) async {
    final session = ref.read(sessionProvider);
    if (session.status != SessionStatus.authenticated) return;

    final wasFavorite = state.isFavorite(businessId);
    final liked = !wasFavorite;

    final previousIds = state.favoriteBusinessIds;
    final previousBranches = state.branches;

    final optimisticIds = Set<int>.from(previousIds);
    var optimisticBranches = List<MapBranchModel>.from(previousBranches);

    if (liked) {
      optimisticIds.add(businessId);
      if (branch != null &&
          !optimisticBranches.any((b) => b.businessId == businessId)) {
        optimisticBranches = [branch, ...optimisticBranches];
      }
    } else {
      optimisticIds.remove(businessId);
      optimisticBranches =
          optimisticBranches.where((b) => b.businessId != businessId).toList();
    }

    state = state.copyWith(
      favoriteBusinessIds: optimisticIds,
      branches: optimisticBranches,
      clearError: true,
    );

    final result = await EngagementService.instance.setBusinessLike(
      businessId,
      liked: liked,
    );

    if (!ref.mounted) return;

    await result.fold(
      (failure) async {
        state = state.copyWith(
          favoriteBusinessIds: previousIds,
          branches: previousBranches,
          errorMessage: failure.message,
        );
        AppLogger.warning(
          'Failed to sync business favorite: ${failure.message}',
        );
      },
      (engagement) async {
        if (engagement.isLiked != liked) {
          await refresh();
          return;
        }

        if (liked &&
            !state.branches.any((b) => b.businessId == businessId)) {
          await refresh();
        }
      },
    );
  }
}
