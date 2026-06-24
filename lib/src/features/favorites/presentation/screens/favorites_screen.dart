import 'package:goluto/src/features/businessStore/presentation/widgets/business_store_card.dart';
import 'package:goluto/src/features/favorites/presentation/providers/favorite_stores_provider.dart';
import 'package:goluto/src/features/shared/data/dummy_berlin_items.dart';
import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = context.theme.colorScheme;
    final favoritesState = ref.watch(favoriteStoresProvider);
    final favoriteItems = dummyBerlinItems
        .where((item) => favoritesState.isFavorite(item.id))
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
        child: favoritesState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : favoriteItems.isEmpty
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
                    itemCount: favoriteItems.length,
                    separatorBuilder: (_, __) =>
                        SizedBox(height: AppSpacing.md.h),
                    itemBuilder: (context, index) {
                      final item = favoriteItems[index];
                      return BusinessStoreCard(
                        item: item,
                        onTap: () => context.push(AppRoutes.businessStore),
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
            SizedBox(height: AppSpacing.xs.h),
            Text(
              'Tap the heart on a store to save it here for quick access.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: AppSpacing.lg.h),
            FilledButton.icon(
              onPressed: onBrowse,
              icon: const Icon(Icons.storefront_outlined),
              label: const Text('Browse stores'),
            ),
          ],
        ),
      ),
    );
  }
}
