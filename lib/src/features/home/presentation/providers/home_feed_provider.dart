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
    this.isLoading = false,
    this.errorMessage,
  });

  final List<CategoryModel> categories;
  final List<MapBranchModel> branches;
  final int selectedCategoryIndex;
  final bool isLoading;
  final String? errorMessage;

  HomeFeedState copyWith({
    List<CategoryModel>? categories,
    List<MapBranchModel>? branches,
    int? selectedCategoryIndex,
    bool? isLoading,
    String? errorMessage,
  }) {
    return HomeFeedState(
      categories: categories ?? this.categories,
      branches: branches ?? this.branches,
      selectedCategoryIndex:
          selectedCategoryIndex ?? this.selectedCategoryIndex,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  List<MapBranchModel> get filteredBranches {
    if (selectedCategoryIndex == 0) return branches;
    final categoryIndex = selectedCategoryIndex - 1;
    if (categoryIndex < 0 || categoryIndex >= categories.length) {
      return branches;
    }
    final categoryId = categories[categoryIndex].id;
    return branches.where((branch) => branch.categoryId == categoryId).toList();
  }

  List<String> get categoryLabels => [
        'All',
        ...categories.map((category) => category.name),
      ];
}

@Riverpod(keepAlive: true)
DiscoveryService discoveryService(Ref ref) {
  return DiscoveryService.instance;
}

@Riverpod(keepAlive: true)
class HomeFeed extends _$HomeFeed {
  late final DiscoveryService _discoveryService;

  @override
  HomeFeedState build() {
    _discoveryService = ref.read(discoveryServiceProvider);

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

  Future<void> load({String? addressId}) async {
    if (!ref.mounted) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await ref.read(savedAddressesProvider.notifier).ensureLoaded();
      if (!ref.mounted) return;

      final resolvedAddressId =
          addressId ?? ref.read(savedAddressesProvider).selectedAddress?.id;

      final categoriesResult = await _discoveryService.getCategories();
      if (!ref.mounted) return;

      final branchesResult = await _discoveryService.getMapBranches(
        addressId: resolvedAddressId,
      );
      if (!ref.mounted) return;

      categoriesResult.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
        },
        (categories) {
          branchesResult.fold(
            (failure) {
              state = state.copyWith(
                categories: categories,
                isLoading: false,
                errorMessage: failure.message,
              );
            },
            (branches) {
              for (final branch in branches) {
                AppLogger.info(
                  '[Branch ${branch.id}] ${branch.displayName} '
                  'logo=${branch.logoUrl ?? 'none'} '
                  'cover=${branch.coverImageUrl ?? 'none'}',
                );
              }

              state = state.copyWith(
                categories: categories,
                branches: branches,
                isLoading: false,
                errorMessage: null,
              );
            },
          );
        },
      );
    } catch (error, stackTrace) {
      AppLogger.error('Failed to load home feed', error, stackTrace);
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Could not load offers. Please try again.',
      );
    }
  }

  void selectCategory(int index) {
    if (index == state.selectedCategoryIndex) return;
    state = state.copyWith(selectedCategoryIndex: index);
  }
}
