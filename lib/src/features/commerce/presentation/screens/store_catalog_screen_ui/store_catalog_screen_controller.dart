part of 'package:aajhee/src/features/commerce/presentation/screens/store_catalog_screen.dart';

mixin StoreCatalogScreenController on ConsumerState<StoreCatalogScreen> {
  CommerceRepository get _api => ref.read(commerceRepositoryProvider);
  Map<String, dynamic>? _catalog;
  bool _loading = true;
  String? _error;

  static const _whatsAppGreen = Color(0xFF25D366);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final addressId = ref.read(savedAddressesProvider).selectedAddress?.id;
    final branchId = widget.args.resolvedBranchId;
    final businessId = widget.args.resolvedBusinessId;

    final result = branchId != null
        ? await _api.getBranchCatalog(branchId, addressId: addressId)
        : businessId != null
            ? await _api.getBusinessCatalog(businessId)
            : null;

    if (!mounted) return;
    if (result == null) {
      setState(() {
        _loading = false;
        _error = 'Shop not found.';
      });
      return;
    }

    result.fold(
      (f) => setState(() {
        _loading = false;
        _error = f.message;
      }),
      (data) => setState(() {
        _catalog = data;
        _loading = false;
      }),
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

  bool _isTrulyDiscounted(Map<String, dynamic> product) {
    if (product['has_discount'] != true) return false;
    final raw = product['effective_discount_percent'];
    final percent =
        raw is num ? raw.toDouble() : double.tryParse('${raw ?? ''}');
    return percent != null && percent > 0;
  }

  String? _pickHours({
    required Map<String, dynamic> business,
    required Map<String, dynamic> branchData,
    MapBranchModel? feedBranch,
  }) {
    for (final source in [branchData, business]) {
      for (final key in ['opening_hours', 'hours', 'business_hours']) {
        final value = source[key]?.toString().trim() ?? '';
        if (value.isNotEmpty) return value;
      }
    }
    final fromBranch = feedBranch?.openingHours?.trim();
    if (fromBranch != null && fromBranch.isNotEmpty) return fromBranch;
    return null;
  }

  bool? _flagFromMaps(
    List<Map<String, dynamic>> maps,
    List<String> keys,
  ) {
    for (final map in maps) {
      for (final key in keys) {
        final value = map[key];
        if (value == true) return true;
        if (value == false) return false;
      }
    }
    return null;
  }

  dynamic _feeFromMaps(List<Map<String, dynamic>> maps) {
    for (final map in maps) {
      final fee = map['delivery_fee'] ?? map['same_day_delivery_fee'];
      if (fee != null) return fee;
    }
    return null;
  }

  bool _listHasSameDay(dynamic fulfillment) {
    if (fulfillment is! List) return false;
    return fulfillment.any((e) => e.toString() == 'local_same_day');
  }

  bool _listHasNationwide(dynamic fulfillment) {
    if (fulfillment is! List) return false;
    return fulfillment.any((e) => e.toString() == 'nationwide');
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  double? _asDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
