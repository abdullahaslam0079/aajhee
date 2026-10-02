part of 'package:aajhee/src/features/commerce/presentation/screens/product_search_screen.dart';

class _ProductSearchScreenState extends ConsumerState<ProductSearchScreen>
    with ProductSearchScreenController {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final query = _controller.text.trim();
    final feed = ref.watch(homeFeedProvider);
    final categories = feed.categories;

    return Scaffold(
      backgroundColor: homeCanvasOf(context),
      appBar: AppBar(
        backgroundColor: homeCanvasOf(context),
        titleSpacing: 0,
        title: TextField(
          controller: _controller,
          focusNode: _focusNode,
          textInputAction: TextInputAction.search,
          onChanged: _onQueryChanged,
          onSubmitted: (value) => _search(value.trim(), persist: true),
          decoration: InputDecoration(
            hintText: 'Search shops & products',
            border: InputBorder.none,
            hintStyle: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
          ),
          style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        actions: [
          if (query.isNotEmpty)
            IconButton(
              tooltip: 'Clear',
              onPressed: () {
                _controller.clear();
                _onQueryChanged('');
              },
              icon: const Icon(Icons.close_rounded),
            ),
        ],
      ),
      body: query.isEmpty
          ? _IdleBody(
              recentSearches: _recentSearches,
              categories: categories,
              suggestedProducts: _suggestedProducts,
              loadingSuggestions: _loadingSuggestions,
              onRecentTap: _applyQueryAndSearch,
              onClearRecent: _clearRecentSearches,
              onCategoryTap: _applyQueryAndSearch,
              onProductTap: _openProduct,
            )
          : _loading
              ? const _SearchLoadingBody()
              : _error != null &&
                      _productResults.isEmpty &&
                      _shopResults.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_error!, textAlign: TextAlign.center),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: () => _search(query),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _productResults.isEmpty && _shopResults.isEmpty
                      ? Center(
                          child: Text(
                            'No results for “$query”',
                            style: tt.bodyMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        )
                      : _ResultsBody(
                          shops: _shopResults,
                          products: _productResults,
                          onShopTap: _openShop,
                          onProductTap: _openProduct,
                        ),
    );
  }
}
