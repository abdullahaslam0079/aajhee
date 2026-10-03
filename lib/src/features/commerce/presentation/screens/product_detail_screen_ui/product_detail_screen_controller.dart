part of 'package:aajhee/src/features/commerce/presentation/screens/product_detail_screen.dart';

mixin ProductDetailScreenController on ConsumerState<ProductDetailScreen> {
  CommerceRepository get _api => ref.read(commerceRepositoryProvider);
  Map<String, dynamic>? _product;
  List<Map<String, dynamic>> _suggestions = const [];
  List<Map<String, dynamic>> _reviews = const [];
  bool _loading = true;
  bool _adding = false;

  int get _productId => int.parse(widget.productId);

  @override
  void initState() {
    super.initState();
    _product = widget.initial;
    _load();
  }

  Future<void> _load() async {
    await _api.viewProduct(_productId);
    final productResult = await _api.getProduct(
      _productId,
      branchId: widget.branchId,
    );
    final suggestionsResult = await _api.listProducts(page: 1, pageSize: 12);
    final reviewsResult = await _api.getProductReviews(
      _productId,
      page: 1,
      branchId: widget.branchId,
    );
    if (!mounted) return;

    productResult.fold(
      (f) {
        setState(() => _loading = false);
        if (_product == null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(f.message)),
          );
        }
      },
      (p) => setState(() {
        _product = p;
        _loading = false;
      }),
    );

    suggestionsResult.fold((_) {}, (page) {
      final list = page.products
          .where((product) => product.id != _productId)
          .take(10)
          .map((product) => product.json)
          .toList();
      if (!mounted) return;
      setState(() => _suggestions = list);
    });

    reviewsResult.fold((_) {}, (data) {
      final raw = data['results'];
      if (raw is! List) return;
      final list = raw
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      if (!mounted) return;
      setState(() => _reviews = list);
    });
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  MapBranchModel? _branchForBusiness(int? businessId) {
    if (businessId == null || businessId <= 0) return null;
    final branches = ref.read(homeFeedProvider).branches;
    for (final branch in branches) {
      if (branch.businessId == businessId) return branch;
    }
    return null;
  }

  bool _isVerifiedSeller(Map<String, dynamic> product, MapBranchModel? branch) {
    if (branch?.isVerified ?? false) return true;
    if (product['is_verified'] == true || product['verified'] == true) {
      return true;
    }
    final business = product['business'];
    if (business is Map) {
      if (business['is_verified'] == true || business['verified'] == true) {
        return true;
      }
    }
    return false;
  }

  dynamic _deliveryFeeValue(
    Map<String, dynamic> product,
    MapBranchModel? branch,
  ) {
    final fromProduct =
        product['delivery_fee'] ?? product['same_day_delivery_fee'];
    if (fromProduct != null) return fromProduct;

    final business = product['business'];
    if (business is Map) {
      final fromBusiness =
          business['delivery_fee'] ?? business['same_day_delivery_fee'];
      if (fromBusiness != null) return fromBusiness;
    }

    return branch?.deliveryFee;
  }

  bool _supportsSameDay(
    Map<String, dynamic> product,
    MapBranchModel? branch,
  ) {
    if (branch != null) return branch.treatsAsSameDay;

    final business = product['business'];
    if (business is Map) {
      if (business['supports_same_day'] == true ||
          business['same_day_enabled'] == true ||
          business['same_day_delivery'] == true) {
        return true;
      }
      if (business['supports_same_day'] == false) return false;
      final fulfillment =
          business['fulfillment_types'] ?? business['fulfillment_modes'];
      if (fulfillment is List &&
          fulfillment.any((e) => e.toString() == 'local_same_day')) {
        return true;
      }
    }

    if (product['supports_same_day'] == true ||
        product['same_day_enabled'] == true ||
        product['same_day_delivery'] == true) {
      return true;
    }
    return false;
  }

  void _openStore(Map<String, dynamic> product) {
    final businessId = _asInt(product['business_id']);
    if (businessId == null) return;
    final branchIds = product['branch_ids'];
    var branchId = widget.branchId;
    if (branchId == null && branchIds is List && branchIds.isNotEmpty) {
      branchId = _asInt(branchIds.first);
    }
    final logoUrl = ref.read(homeFeedProvider).logoUrlForBusiness(businessId);
    context.push(
      AppRoutes.businessStore,
      extra: StoreCatalogArgs(
        businessId: businessId,
        branchId: branchId,
        businessName: product['business_name']?.toString(),
        logoUrl: logoUrl,
        branch: _branchForBusiness(businessId),
      ),
    );
  }

  void _openProduct(Map<String, dynamic> product) {
    final id = product['id'];
    if (id == null) return;
    context.push(
      AppRoutes.productDetail('$id'),
      extra: product,
    );
  }

  Future<void> _addToCart() async {
    final product = _product;
    if (product == null || _adding) return;
    setState(() => _adding = true);
    final ok = await ref.read(cartProvider.notifier).addProduct(
          productId: _asInt(product['id']) ?? _productId,
          branchId: widget.branchId,
        );
    if (!mounted) return;
    setState(() => _adding = false);
    if (!ok) {
      final message = ref.read(cartProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message ?? 'Could not add to cart')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Added to cart'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () => context.push(AppRoutes.cart),
        ),
      ),
    );
  }

  Future<void> _changeQuantity({
    required int itemId,
    required int nextQty,
  }) async {
    final notifier = ref.read(cartProvider.notifier);
    final ok = nextQty < 1
        ? await notifier.remove(itemId)
        : await notifier.setQuantity(itemId, nextQty);
    if (!mounted) return;
    if (!ok) {
      final message = ref.read(cartProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message ?? 'Could not update cart')),
      );
    }
  }
}
