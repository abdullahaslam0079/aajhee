import 'package:goluto/src/features/businessStore/presentation/widgets/business_store_card.dart';
import 'package:goluto/src/features/favorites/presentation/providers/favorite_stores_provider.dart';
import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';

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
            ? const Center(child: CircularProgressIndicator())
            : favoritesState.errorMessage != null && favoriteBranches.isEmpty
                ? _FavoritesError(
                    message: favoritesState.errorMessage!,
                    onRetry: () =>
                        ref.read(favoriteStoresProvider.notifier).refresh(),
                  )
                : favoriteBranches.isEmpty
                    ? _EmptyFavorites(
                        onBrowse: () => context.go(AppRoutes.bottomNavigator),
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
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
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

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites({required this.onBrowse});

  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final textTheme = context.theme.textTheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border_rounded,
              size: 56,
              color: colorScheme.primary.withValues(alpha: 0.7),
            ),
            SizedBox(height: AppSpacing.md.h),
            Text(
              'No favorites yet',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: AppSpacing.sm.h),
            Text(
              'Tap the heart on a store to save it here.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: AppSpacing.lg.h),
            FilledButton(onPressed: onBrowse, child: const Text('Browse stores')),
          ],
        ),
      ),
    );
  }
}

class _FavoritesError extends StatelessWidget {
  const _FavoritesError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final textTheme = context.theme.textTheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: colorScheme.error,
            ),
            SizedBox(height: AppSpacing.md.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: AppSpacing.lg.h),
            FilledButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
