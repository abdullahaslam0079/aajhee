part of 'package:aajhee/src/features/commerce/presentation/screens/checkout_screen.dart';

mixin CheckoutScreenController on ConsumerState<CheckoutScreen> {
  CommerceRepository get _api => ref.read(commerceRepositoryProvider);
  final _notesController = TextEditingController();
  final _phoneController = TextEditingController();
  final _houseController = TextEditingController();
  final _landmarkController = TextEditingController();

  List<_CheckoutGroup> _groups = const [];
  final Map<int, XFile?> _paymentProofs = {};
  bool _loading = true;
  bool _placing = false;
  String? _error;
  String? _lastAddressId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final phone = ref.read(userProfileProvider).profile.phone;
      if (phone != null && phone.trim().isNotEmpty) {
        _phoneController.text = formatPakistaniMobileLocal(phone);
      }
      _applyAddressFields(ref.read(savedAddressesProvider).selectedAddress);
      _load();
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    _phoneController.dispose();
    _houseController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  void _applyAddressFields(SavedAddress? address) {
    _lastAddressId = address?.id;
    _houseController.text = address?.houseNumber ?? '';
    _landmarkController.text = address?.landmark ?? '';
  }

  bool get _needsDelivery =>
      _groups.any((g) => isDeliveryFulfillment(g.fulfillmentType));

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final addressId = ref.read(savedAddressesProvider).selectedAddress?.id;
    final cartResult = await _api.getCart();
    if (!mounted) return;

    final cart = cartResult.fold((f) {
      setState(() {
        _loading = false;
        _error = f.message;
      });
      return null;
    }, (data) => data);
    if (cart == null) return;

    final items = cart.items;
    if (items.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Your cart is empty.';
      });
      return;
    }

    final grouped = <int, List<CartLine>>{};
    for (final item in items) {
      final branchId = _resolveBranchId(item);
      if (branchId == null) {
        setState(() {
          _loading = false;
          _error =
              'Open a store to add items with a pickup location, or set product branches.';
        });
        return;
      }
      grouped.putIfAbsent(branchId, () => []).add(item);
    }

    final groups = <_CheckoutGroup>[];
    for (final entry in grouped.entries) {
      final previewResult = await _api.checkoutPreview(
        branchId: entry.key,
        itemIds: entry.value.map((e) => e.id).toList(),
        addressId: addressId,
      );
      if (!mounted) return;

      final preview = previewResult.fold((f) {
        setState(() {
          _loading = false;
          _error = f.message;
        });
        return null;
      }, (data) => data);
      if (preview == null) return;

      final options = preview.options;
      if (options.isEmpty) {
        setState(() {
          _loading = false;
          _error = 'No delivery options available.';
        });
        return;
      }

      final fulfillment = options.first.fulfillmentType.isEmpty
          ? 'pickup'
          : options.first.fulfillmentType;
      final temp = _CheckoutGroup(
        branchId: entry.key,
        items: entry.value,
        preview: preview,
        fulfillmentType: fulfillment,
        paymentMethod: '',
      );
      final methods = temp.availablePaymentMethods();
      if (methods.isEmpty) {
        setState(() {
          _loading = false;
          _error = 'No payment methods available.';
        });
        return;
      }
      temp.paymentMethod = methods.first;
      groups.add(temp);
    }

    setState(() {
      _groups = groups;
      _loading = false;
    });
  }

  int? _resolveBranchId(CartLine item) => item.checkoutBranchId;

  void _setFulfillment(_CheckoutGroup group, String type) {
    setState(() {
      group.fulfillmentType = type;
      final methods = group.availablePaymentMethods();
      if (!methods.contains(group.paymentMethod)) {
        group.paymentMethod = methods.isEmpty ? '' : methods.first;
      }
    });
  }

  Future<void> _pickPaymentProof(int groupIndex) async {
    final colors = Theme.of(context).colorScheme;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final labelStyle =
            Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                );
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.photo_library_outlined,
                  color: colors.onSurface,
                ),
                title: Text('Choose from gallery', style: labelStyle),
                onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
              ),
              ListTile(
                leading: Icon(
                  Icons.photo_camera_outlined,
                  color: colors.onSurface,
                ),
                title: Text('Take a photo', style: labelStyle),
                onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );
    if (source == null || !mounted) return;

    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;

    try {
      final result = await ImagePicker().pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 2000,
        requestFullMetadata: false,
      );
      if (result == null || !mounted) return;
      setState(() => _paymentProofs[groupIndex] = result);
    } on PlatformException catch (e) {
      if (!mounted) return;
      final needsRebuild = e.code == 'channel-error';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            needsRebuild
                ? 'Photo picker needs a full app restart. Stop the app and run again.'
                : (e.message ?? 'Could not open the photo picker.'),
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the photo picker.')),
      );
    }
  }

  Future<void> _placeOrder() async {
    if (_placing || _groups.isEmpty) return;

    final houseNumber = _houseController.text.trim();
    final landmark = _landmarkController.text.trim();
    final selectedAddress = ref.read(savedAddressesProvider).selectedAddress;
    final placeError = checkoutPlaceError(
      phone: _phoneController.text,
      hasDeliveryAddress: selectedAddress != null,
      houseNumber: houseNumber,
      groups: [
        for (var i = 0; i < _groups.length; i++)
          CheckoutPlaceGroup(
            fulfillmentType: _groups[i].fulfillmentType,
            paymentMethod: _groups[i].paymentMethod,
            storeName: _groups[i].storeName,
            hasPaymentProof: _paymentProofs[i] != null,
          ),
      ],
    );
    if (placeError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(placeError)),
      );
      return;
    }
    final customerPhone = normalizePakistaniMobile(_phoneController.text)!;

    final notes = _notesController.text.trim();
    final checkoutGroups = <Map<String, dynamic>>[];
    for (var i = 0; i < _groups.length; i++) {
      final group = _groups[i];
      checkoutGroups.add(
        buildCheckoutGroupPayload(
          CheckoutGroupDraft(
            branchId: group.branchId,
            itemIds: group.items.map((item) => item.id).toList(),
            fulfillmentType: group.fulfillmentType,
            paymentMethod: group.paymentMethod,
            houseNumber: houseNumber,
            landmark: landmark,
            customerPhone: customerPhone,
            deliveryAddressText: selectedAddress?.formattedAddress ??
                selectedAddress?.shortLabel ??
                '',
            addressInstructions:
                selectedAddress?.deliveryInstructions.trim() ?? '',
            notes: notes,
          ),
        ),
      );
    }

    final paymentProofs = <int, UploadFile>{};
    for (final entry in _paymentProofs.entries) {
      final file = entry.value;
      if (file == null) continue;
      paymentProofs[entry.key] = UploadFile(
        path: file.path,
        filename: file.name,
      );
    }

    setState(() => _placing = true);
    final placed = await _api.placeOrders(
      groups: checkoutGroups,
      addressId: selectedAddress?.id,
      customerPhone: customerPhone,
      paymentProofs: paymentProofs.isEmpty ? null : paymentProofs,
    );
    if (!mounted) return;
    setState(() => _placing = false);

    await placed.fold(
      (f) async {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(f.message)),
        );
      },
      (orders) async {
        final profile = ref.read(userProfileProvider).profile;
        try {
          await ref.read(userProfileProvider.notifier).updateProfile(
                name: profile.name.isNotEmpty
                    ? profile.name
                    : profile.displayName,
                phone: customerPhone,
              );
        } catch (_) {
          // Order already placed; phone save is best-effort.
        }
        if (!mounted) return;
        unawaited(ref.read(cartProvider.notifier).refresh());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Placed ${orders.length} order(s)')),
        );
        context.go(AppRoutes.orders);
      },
    );
  }

  double get _grandTotal =>
      _groups.fold<double>(0, (sum, group) => sum + group.total);

  double get _itemsTotal =>
      _groups.fold<double>(0, (sum, group) => sum + group.itemsSubtotal);

  double get _feesTotal =>
      _groups.fold<double>(0, (sum, group) => sum + group.deliveryFee);

  String? _paymentSubtitle(_CheckoutGroup group, String method) {
    if (method == 'bank_transfer') {
      final iban = group.payments.iban;
      if (iban != null) return 'IBAN · $iban';
      return 'Pay by bank transfer, then upload your receipt';
    }
    if (method == 'stripe') {
      return 'Pay by card, then upload your transaction screenshot';
    }
    if (method == 'jazzcash') {
      return 'Pay via JazzCash, then upload your transaction screenshot';
    }
    if (method == 'cash_on_delivery') {
      return 'Pay when your order arrives';
    }
    if (method == 'cash_on_pickup') {
      return 'Pay when you collect the order';
    }
    return null;
  }
}
