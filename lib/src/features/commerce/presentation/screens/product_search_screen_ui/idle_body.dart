part of 'package:aajhee/src/features/commerce/presentation/screens/product_search_screen.dart';

class _IdleBody extends StatelessWidget {
  const _IdleBody({
    required this.recentSearches,
    required this.categories,
    required this.suggestedProducts,
    required this.loadingSuggestions,
    required this.onRecentTap,
    required this.onClearRecent,
    required this.onCategoryTap,
    required this.onProductTap,
  });

  final List<String> recentSearches;
  final List<CategoryModel> categories;
  final List<CommerceProduct> suggestedProducts;
  final bool loadingSuggestions;
  final ValueChanged<String> onRecentTap;
  final VoidCallback onClearRecent;
  final ValueChanged<String> onCategoryTap;
  final ValueChanged<CommerceProduct> onProductTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
      children: [
        if (recentSearches.isNotEmpty) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  'Recent searches',
                  style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              TextButton(
                onPressed: onClearRecent,
                child: const Text('Clear'),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              for (final term in recentSearches)
                ActionChip(
                  avatar: Icon(
                    Icons.history_rounded,
                    size: 16.r,
                    color: cs.onSurfaceVariant,
                  ),
                  label: Text(term),
                  onPressed: () => onRecentTap(term),
                ),
            ],
          ),
          SizedBox(height: 20.h),
        ],
        if (categories.isNotEmpty) ...[
          Text(
            'Popular categories',
            style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              for (final category in categories)
                ActionChip(
                  avatar: Icon(
                    categoryIconForName(category.name),
                    size: 16.r,
                    color: cs.primary,
                  ),
                  label: Text(category.name),
                  onPressed: () => onCategoryTap(category.name),
                ),
            ],
          ),
          SizedBox(height: 20.h),
        ],
        Text(
          'Suggested for you',
          style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 10.h),
        if (loadingSuggestions)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (suggestedProducts.isEmpty)
          Text(
            'No suggestions yet',
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          )
        else ...[
          for (var i = 0; i < suggestedProducts.length; i++) ...[
            if (i > 0) SizedBox(height: 10.h),
            _SearchProductTile(
              product: suggestedProducts[i],
              onTap: () => onProductTap(suggestedProducts[i]),
            ),
          ],
        ],
      ],
    );
  }
}
