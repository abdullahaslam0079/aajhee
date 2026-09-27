import 'dart:async';

import 'package:aajhee/src/features/commerce/data/commerce_api_service.dart';
import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';

class ProductSearchScreen extends StatefulWidget {
  const ProductSearchScreen({super.key});

  @override
  State<ProductSearchScreen> createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  final _api = CommerceApiService(DioService.instance);
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  List<Map<String, dynamic>> _results = const [];
  Timer? _debounce;
  bool _loading = false;
  String? _error;
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 320), () {
      _search(value.trim());
    });
  }

  Future<void> _search(String query) async {
    if (query == _lastQuery && _results.isNotEmpty) return;
    _lastQuery = query;
    if (query.isEmpty) {
      setState(() {
        _results = const [];
        _loading = false;
        _error = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await _api.listProducts(page: 1, pageSize: 40, query: query);
    if (!mounted || query != _lastQuery) return;
    result.fold(
      (f) => setState(() {
        _loading = false;
        _error = f.message;
        _results = const [];
      }),
      (data) {
        final raw = data['results'];
        final list = raw is List
            ? raw
                .whereType<Map<dynamic, dynamic>>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList()
            : <Map<String, dynamic>>[];
        setState(() {
          _loading = false;
          _results = list;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final query = _controller.text.trim();

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
          onSubmitted: (value) => _search(value.trim()),
          decoration: InputDecoration(
            hintText: 'Search products',
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
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
              : query.isEmpty
                  ? Center(
                      child: Text(
                        'Search for products by name',
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    )
                  : _results.isEmpty
                      ? Center(
                          child: Text(
                            'No products match “$query”',
                            style: tt.bodyMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
                          itemCount: _results.length,
                          separatorBuilder: (_, __) => SizedBox(height: 10.h),
                          itemBuilder: (context, index) {
                            final product = _results[index];
                            return _SearchProductTile(
                              product: product,
                              onTap: () => context.push(
                                AppRoutes.productDetail('${product['id']}'),
                                extra: product,
                              ),
                            );
                          },
                        ),
    );
  }
}

class _SearchProductTile extends StatelessWidget {
  const _SearchProductTile({
    required this.product,
    required this.onTap,
  });

  final Map<String, dynamic> product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final hasDiscount = product['has_discount'] == true;
    final imageUrl = product['image_url']?.toString();

    return Material(
      color: cs.surfaceContainerLowest,
      borderRadius: AppBorders.card,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorders.card,
        child: Padding(
          padding: EdgeInsets.all(10.r),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: AppBorders.md,
                child: SizedBox(
                  width: 64.w,
                  height: 64.w,
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? Image.network(imageUrl, fit: BoxFit.cover)
                      : ColoredBox(
                          color: cs.surfaceContainerHighest,
                          child: const Icon(Icons.image_outlined),
                        ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name']?.toString() ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      hasDiscount
                          ? 'Rs ${product['effective_price']} · ${product['effective_discount_percent']}% off'
                          : 'Rs ${product['effective_price'] ?? product['base_price']}',
                      style: tt.bodySmall?.copyWith(
                        color: hasDiscount
                            ? context.appColors.deal
                            : cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
