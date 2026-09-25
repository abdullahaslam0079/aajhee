import 'package:aajhee/src/features/commerce/data/commerce_api_service.dart';
import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';
import 'package:aajhee/src/services/dio_service.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    super.key,
    required this.productId,
    this.initial,
    this.branchId,
  });

  final String productId;
  final Map<String, dynamic>? initial;
  final int? branchId;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _api = CommerceApiService(DioService.instance);
  Map<String, dynamic>? _product;
  bool _loading = true;
  bool _adding = false;

  @override
  void initState() {
    super.initState();
    _product = widget.initial;
    _load();
  }

  Future<void> _load() async {
    final id = int.parse(widget.productId);
    await _api.viewProduct(id);
    final result = await _api.getProduct(id);
    if (!mounted) return;
    result.fold(
      (f) => setState(() {
        _loading = false;
        if (_product == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(f.message)),
          );
        }
      }),
      (p) => setState(() {
        _product = p;
        _loading = false;
      }),
    );
  }

  Future<void> _addToCart() async {
    final product = _product;
    if (product == null) return;
    setState(() => _adding = true);
    final result = await _api.addToCart(
      productId: product['id'] as int,
      branchId: widget.branchId,
    );
    if (!mounted) return;
    setState(() => _adding = false);
    result.fold(
      (f) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(f.message)),
      ),
      (_) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added to cart')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = _product;
    final hasDiscount = product?['has_discount'] == true;
    return Scaffold(
      appBar: AppBar(title: Text(product?['name']?.toString() ?? 'Product')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _adding || product == null ? null : _addToCart,
            child: _adding
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Add to cart'),
          ),
        ),
      ),
      body: _loading && product == null
          ? const Center(child: CircularProgressIndicator())
          : product == null
              ? const Center(child: Text('Product not found'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    AspectRatio(
                      aspectRatio: 1.2,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                          image: product['image_url'] != null
                              ? DecorationImage(
                                  image: NetworkImage(
                                    product['image_url'].toString(),
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      product['name']?.toString() ?? '',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hasDiscount
                          ? 'Rs ${product['effective_price']}  (${product['effective_discount_percent']}% off · was Rs ${product['base_price']})'
                          : 'Rs ${product['base_price']}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(product['description']?.toString() ?? ''),
                    if ((product['detailed_description'] ?? '')
                        .toString()
                        .isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(product['detailed_description'].toString()),
                    ],
                  ],
                ),
    );
  }
}
