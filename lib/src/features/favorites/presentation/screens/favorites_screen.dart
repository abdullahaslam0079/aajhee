import 'package:aajhee/src/features/businessStore/presentation/widgets/business_store_card.dart';
import 'package:aajhee/src/features/favorites/presentation/providers/favorite_stores_provider.dart';
import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 240) {
      ref.read(favoriteStoresProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final favoritesState = ref.watch(favoriteStoresProvider);
    final favoriteBranches = favoritesState.branches;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Favorites'),
        centerTitle: false,
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.surface,
      ),
      body: SafeArea(
        child: favoritesState.isLoading && favoriteBranches.isEmpty
            ? const AppLoading(message: 'Loading favorites...')
            : favoritesState.errorMessage != null && favoriteBranches.isEmpty
                ? AppErrorWidget(
                    title: 'Could not load favorites',
                    message: favoritesState.errorMessage,
                    onRetry: () =>
                        ref.read(favoriteStoresProvider.notifier).refresh(),
                  )
                : favoriteBranches.isEmpty
                    ? AppEmptyState(
                        icon: Icons.favorite_border_rounded,
                        title: 'No favorites yet',
                        subtitle: 'Tap the heart on a store to save it here.',
                        actionLabel: 'Browse stores',
                        onAction: () => context.go(AppRoutes.bottomNavigator),
                      )
                    : RefreshIndicator(
                        onRefresh: () =>
                            ref.read(favoriteStoresProvider.notifier).refresh(),
                        child: ListView.separated(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.sm.w,
                            AppSpacing.sm.h,
                            AppSpacing.sm.w,
                            AppSpacing.lg.h,
                          ),
                          itemCount: favoriteBranches.length +
                              (favoritesState.isLoadingMore ? 1 : 0),
                          separatorBuilder: (_, __) =>
                              SizedBox(height: AppSpacing.md.h),
                          itemBuilder: (context, index) {
                            if (index >= favoriteBranches.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: AppLoading(size: 22, strokeWidth: 2.5),
                              );
                            }
                            final branch = favoriteBranches[index];
                            return BusinessStoreCard(
                              branch: branch,
                              onTap: () => context.push(
                                AppRoutes.businessStore,
                                extra: branch,
                              ),
                            );
                          },
                        ),
                      ),
      ),
    );
  }
}

