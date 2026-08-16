import 'package:goluto/src/features/home/data/models/category_model.dart';
import 'package:goluto/src/features/home/data/models/map_branch_model.dart';
import 'package:goluto/src/features/home/data/services/discovery_service.dart';
import 'package:goluto/src/features/settings/presentation/providers/saved_addresses_provider.dart';
import 'package:goluto/src/utils/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_feed_provider.g.dart';

class HomeFeedState {
  const HomeFeedState({
    this.categories = const [],
    this.branches = const [],
    this.selectedCategoryIndex = 0,
    this.page = 0,
    this.hasMore = false,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final List<CategoryModel> categories;
  final List<MapBranchModel> branches;
  final int selectedCategoryIndex;
  final int page;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;

  HomeFeedState copyWith({
    List<CategoryModel>? categories,
    List<MapBranchModel>? branches,
    int? selectedCategoryIndex,
    int? page,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
  }) {
    return HomeFeedState(
      categories: categories ?? this.categories,
      branches: branches ?? this.branches,
      selectedCategoryIndex:
          selectedCategoryIndex ?? this.selectedCategoryIndex,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  /// Branches are already filtered server-side by [selectedCategoryIndex].
  List<MapBranchModel> get filteredBranches => branches;

  String? logoUrlForBusiness(int businessId) {
    if (businessId <= 0) return null;
    for (final branch in branches) {
      if (branch.businessId != businessId) continue;
      final url = branch.businessLogoUrl?.trim();
      if (url != null && url.isNotEmpty) return url;
    }
    return null;
  }

  List<String> get categoryLabels => [
        'All',
        ...categories.map((category) => category.name),
      ];

  int? get selectedCategoryId {
    if (selectedCategoryIndex <= 0) return null;
    final categoryIndex = selectedCategoryIndex - 1;
    if (categoryIndex < 0 || categoryIndex >= categories.length) return null;
    return categories[categoryIndex].id;
  }
}

@Riverpod(keepAlive: true)
DiscoveryService discoveryService(Ref ref) {
  return DiscoveryService.instance;
}

@Riverpod(keepAlive: true)
class HomeFeed extends _$HomeFeed {
  static const _pageSize = 20;

  DiscoveryService get _discoveryService => ref.read(discoveryServiceProvider);
  int _requestId = 0;

  @override
  HomeFeedState build() {
    ref.listen(savedAddressesProvider, (previous, next) {
      if (next.isLoading) return;
      if (previous == null || previous.isLoading) return;

      final nextAddressId = next.selectedAddress?.id;
      if (previous.selectedAddress != next.selectedAddress) {
        _scheduleLoad(nextAddressId);
      }
    });

    _scheduleLoad(null);
    return const HomeFeedState(isLoading: true);
  }

  void _scheduleLoad(String? addressId) {
    Future.microtask(() => load(addressId: addressId));
  }

  Future<void> load({String? addressId}) => _fetch(reset: true, addressId: addressId);

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading || state.isLoadingMore) return;
    await _fetch(reset: false);
  }

  Future<void> _fetch({required bool reset, String? addressId}) async {
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

      final resolvedAddressId =
          addressId ?? ref.read(savedAddressesProvider).selectedAddress?.id;

      List<CategoryModel> categories = state.categories;
      if (reset || categories.isEmpty) {
        final categoriesResult = await _discoveryService.getCategories();
        if (!ref.mounted || requestId != _requestId) return;

        final failed = categoriesResult.fold<String?>((f) => f.message, (_) => null);
        if (failed != null) {
          state = state.copyWith(
            isLoading: false,
            isLoadingMore: false,
            errorMessage: failed,
          );
          return;
        }
        categories = categoriesResult.getOrElse((_) => const []);
      }

      final categoryId = () {
        if (state.selectedCategoryIndex <= 0) return null;
        final categoryIndex = state.selectedCategoryIndex - 1;
        if (categoryIndex < 0 || categoryIndex >= categories.length) return null;
        return categories[categoryIndex].id;
      }();

      final branchesResult = await _discoveryService.getMapBranches(
        addressId: resolvedAddressId,
        categoryId: categoryId,
        page: nextPage,
        pageSize: _pageSize,
      );
      if (!ref.mounted || requestId != _requestId) return;

      branchesResult.fold(
        (failure) {
          state = state.copyWith(
            categories: categories,
            isLoading: false,
            isLoadingMore: false,
            errorMessage: failure.message,
          );
        },
        (page) {
          final branches = reset
              ? page.results
              : [...state.branches, ...page.results];
          state = state.copyWith(
            categories: categories,
            branches: branches,
            page: page.page,
            hasMore: page.hasMore,
            isLoading: false,
            isLoadingMore: false,
            clearError: true,
          );
        },
      );
    } catch (error, stackTrace) {
      AppLogger.error('Failed to load home feed', error, stackTrace);
      if (!ref.mounted || requestId != _requestId) return;
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        errorMessage: 'Could not load offers. Please try again.',
      );
    }
  }

  void selectCategory(int index) {
    if (index == state.selectedCategoryIndex) return;
    state = state.copyWith(selectedCategoryIndex: index);
    Future.microtask(() => load());
  }
}
