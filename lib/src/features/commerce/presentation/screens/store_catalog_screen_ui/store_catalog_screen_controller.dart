part of 'package:aajhee/src/features/commerce/presentation/screens/store_catalog_screen.dart';

mixin StoreCatalogScreenController on ConsumerState<StoreCatalogScreen> {
  CommerceRepository get _api => ref.read(commerceRepositoryProvider);
  StoreHeader? _header;
  StoreHome? _home;
  bool _loading = true;
  String? _error;
  int _tabIndex = 0;

  static const _whatsAppGreen = Color(0xFF25D366);

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _selectTab(int index) {
    if (_tabIndex == index) return;
    setState(() => _tabIndex = index);
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final addressId = ref.read(savedAddressesProvider).selectedAddress?.id;
    final branchId = widget.args.resolvedBranchId;
    final businessId = widget.args.resolvedBusinessId;

    if (branchId == null && businessId == null) {
      setState(() {
        _loading = false;
        _error = 'Shop not found.';
      });
      return;
    }

    final headerFuture = _api.getStoreHeader(
      branchId: branchId,
      businessId: businessId,
      addressId: addressId,
    );
    final homeFuture = _api.getStoreHome(
      branchId: branchId,
      businessId: businessId,
      addressId: addressId,
    );

    final headerResult = await headerFuture;
    final homeResult = await homeFuture;
    if (!mounted) return;

    String? error;
    StoreHeader? header;
    StoreHome? home;

    headerResult.fold(
      (f) => error = f.message,
      (data) => header = data,
    );
    homeResult.fold(
      (f) => error ??= f.message,
      (data) => home = data,
    );

    setState(() {
      _header = header;
      _home = home;
      _loading = false;
      _error = header == null ? (error ?? 'Shop not found.') : null;
    });
  }

  void _openCategoryBrowse({
    required String storeName,
    required List<StoreBrowseTab> tabs,
    required int initialIndex,
    int? branchId,
    int? businessId,
  }) {
    if (tabs.isEmpty) return;
    final max = tabs.length - 1;
    context.push(
      AppRoutes.storeCategories,
      extra: StoreCategoryBrowseArgs(
        storeName: storeName,
        tabs: tabs,
        branchId: branchId,
        businessId: businessId,
        initialIndex: initialIndex.clamp(0, max),
      ),
    );
  }

  Future<void> _contact(Map<String, dynamic> contact) async {
    final type = contact['contact_type']?.toString();
    final value = contact['value']?.toString() ?? '';
    if (value.isEmpty) return;
    final launcher = UrlLauncherService.instance;
    if (type == 'email') {
      await launcher.launch('mailto:$value');
    } else if (type == 'phone') {
      await launcher.launch('tel:$value');
    } else {
      await launcher.launch(value);
    }
  }

  Future<void> _openGoogleMaps({
    required double latitude,
    required double longitude,
  }) async {
    final mapsUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=$latitude,$longitude'
      '&travelmode=driving',
    );

    final launched = await launchUrl(
      mapsUri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched && mounted) {
      final fallback = await UrlLauncherService.instance.launchMapDirections(
        latitude: latitude,
        longitude: longitude,
      );
      if (!mounted) return;
      fallback.fold(
        (f) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(f.message)),
        ),
        (_) {},
      );
    }
  }

  void _openProduct(CommerceProduct product, int? branchId) {
    final id = product.id;
    if (id == null) return;
    final path = branchId != null
        ? '${AppRoutes.productDetail('$id')}?branch_id=$branchId'
        : AppRoutes.productDetail('$id');
    context.push(path, extra: product.toJson());
  }

  Future<void> _addProductToCart(
    CommerceProduct product, {
    int? branchId,
  }) async {
    final productId = product.id;
    if (productId == null) return;
    final resolvedBranch =
        product.branchId ?? branchId ?? widget.args.resolvedBranchId;
    final ok = await ref.read(cartProvider.notifier).addProduct(
          productId: productId,
          branchId: resolvedBranch,
        );
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    if (ok) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Added to bag')),
      );
    } else {
      final message = ref.read(cartProvider).errorMessage;
      messenger.showSnackBar(
        SnackBar(content: Text(message ?? 'Could not add to bag')),
      );
    }
  }

  Future<void> _toggleFavorite(int? branchId, MapBranchModel? branch) async {
    if (branchId == null || branchId <= 0) return;
    await ref.read(favoriteStoresProvider.notifier).toggle(
          branchId,
          branch: branch,
        );
  }

  MapBranchModel? _matchingFeedBranch(int? businessId) {
    if (businessId == null || businessId <= 0) return null;
    if (widget.args.branch != null &&
        widget.args.branch!.businessId == businessId) {
      return widget.args.branch;
    }
    for (final branch in ref.read(homeFeedProvider).branches) {
      if (branch.businessId == businessId) return branch;
    }
    return null;
  }

  String? _pickHours({
    required StoreHeader? header,
    MapBranchModel? feedBranch,
  }) {
    final hours = header?.business.businessHours;
    if (hours is String && hours.trim().isNotEmpty) return hours.trim();
    final fromBranch = feedBranch?.openingHours?.trim();
    if (fromBranch != null && fromBranch.isNotEmpty) return fromBranch;
    return widget.args.branch?.openingHours?.trim().isNotEmpty == true
        ? widget.args.branch!.openingHours!.trim()
        : null;
  }

  String? _pickCategoryName(MapBranchModel? feedBranch) {
    final fromBranch = feedBranch?.categoryName.trim();
    if (fromBranch != null && fromBranch.isNotEmpty) return fromBranch;
    final argsCategory = widget.args.branch?.categoryName.trim();
    if (argsCategory?.isNotEmpty ?? false) return argsCategory;
    return null;
  }

  double? _distanceKm(MapBranchModel? feedBranch) {
    final fromBranch = feedBranch?.distanceKm ?? widget.args.branch?.distanceKm;
    if (fromBranch != null) return fromBranch;

    final selected = ref.read(savedAddressesProvider).selectedAddress;
    final lat = selected?.latitude;
    final lng = selected?.longitude;
    final branchLat =
        feedBranch?.latitude ?? _header?.branch?.latitude ?? widget.args.branch?.latitude;
    final branchLng = feedBranch?.longitude ??
        _header?.branch?.longitude ??
        widget.args.branch?.longitude;
    if (lat == null || lng == null || branchLat == null || branchLng == null) {
      return null;
    }
    return GeoDistanceUtils.haversineKm(lat, lng, branchLat, branchLng);
  }

  bool _supportsSameDay({
    required StoreHeader header,
    MapBranchModel? feedBranch,
  }) {
    for (final option in header.deliveryOptions) {
      final type = option['fulfillment_type']?.toString();
      if (type == 'local_same_day' && option['available'] != false) {
        return true;
      }
    }
    return feedBranch?.treatsAsSameDay ??
        widget.args.branch?.treatsAsSameDay ??
        false;
  }

  bool _supportsNationwide({
    required StoreHeader header,
    MapBranchModel? feedBranch,
  }) {
    for (final option in header.deliveryOptions) {
      final type = option['fulfillment_type']?.toString();
      if (type == 'nationwide' && option['available'] != false) {
        return true;
      }
    }
    return feedBranch?.supportsNationwide ??
        widget.args.branch?.supportsNationwide ??
        false;
  }
}
