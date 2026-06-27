import 'package:goluto/src/features/businessStore/presentation/widgets/business_store_card.dart';
import 'package:goluto/src/features/favorites/presentation/providers/favorite_stores_provider.dart';
import 'package:goluto/src/features/home/presentation/providers/home_feed_provider.dart';
import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = context.theme.colorScheme;
    final favoritesState = ref.watch(favoriteStoresProvider);
    final homeFeedState = ref.watch(homeFeedProvider);
    final favoriteBranches = homeFeedState.branches
        .where((branch) => favoritesState.isFavorite(branch.id.toString()))
        .toList();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Favorites'),
        centerTitle: false,
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.surface,
      ),
      body: SafeArea(
        child: favoritesState.isLoading || homeFeedState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : favoriteBranches.isEmpty
                ? _EmptyFavorites(
                    onBrowse: () => context.go(AppRoutes.bottomNavigator),
                  )
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.sm.w,
                      AppSpacing.sm.h,
                      AppSpacing.sm.w,
                      AppSpacing.lg.h,
                    ),
                    itemCount: favoriteBranches.length,
                    separatorBuilder: (_, __) =>
                        SizedBox(height: AppSpacing.md.h),
                    itemBuilder: (context, index) {
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
