import 'dart:async';

import 'package:aajhee/src/features/commerce/data/commerce_api_service.dart';
import 'package:aajhee/src/features/commerce/domain/commerce_labels.dart';
import 'package:aajhee/src/features/commerce/presentation/providers/cart_provider.dart';
import 'package:aajhee/src/features/home/presentation/widgets/delivery_address_picker_sheet.dart';
import 'package:aajhee/src/features/settings/presentation/providers/saved_addresses_provider.dart';
import 'package:aajhee/src/features/settings/presentation/providers/user_profile_provider.dart';
import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutGroup {
  _CheckoutGroup({
    required this.branchId,
    required this.items,
    required this.preview,
    required this.fulfillmentType,
    required this.paymentMethod,
  });

  final int branchId;
  final List<Map<String, dynamic>> items;
  final Map<String, dynamic> preview;
  String fulfillmentType;
  String paymentMethod;

  List<Map<String, dynamic>> get options =>
      (preview['options'] as List? ?? [])
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => Map<String, dynamic>.from(e))
          .where((o) => o['available'] == true)
          .toList();

  Map<String, dynamic> get payments =>
      Map<String, dynamic>.from(preview['payment_methods'] as Map? ?? {});

  Map<String, dynamic>? get selectedOption {
    for (final option in options) {
      if (option['fulfillment_type']?.toString() == fulfillmentType) {
        return option;
      }
    }
    return options.isEmpty ? null : options.first;
  }

  String get storeName {
    for (final item in items) {
      final product = Map<String, dynamic>.from(item['product'] as Map? ?? {});
      final name = product['business_name']?.toString().trim() ?? '';
      if (name.isNotEmpty) return name;
    }
    return 'Store';
  }

  double get itemsSubtotal {
    var sum = 0.0;
    for (final item in items) {
      final line = item['line_total'] ?? item['unit_price'];
      sum += _toDouble(line);
    }
    return sum;
  }

  double get deliveryFee => _toDouble(selectedOption?['fee']);

  double get total => itemsSubtotal + deliveryFee;

  List<String> availablePaymentMethods() {
    final methods = <String>[];
    if (fulfillmentType == 'pickup' && payments['cash_on_pickup'] == true) {
      methods.add('cash_on_pickup');
    }
    if (fulfillmentType != 'pickup' && payments['cash_on_delivery'] == true) {
      methods.add('cash_on_delivery');
    }
    if (payments['bank_transfer'] == true) {
      methods.add('bank_transfer');
    }
    if (payments['stripe'] == true) methods.add('stripe');
    if (payments['jazzcash'] == true) methods.add('jazzcash');
    return methods;
  }
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _api = CommerceApiService(DioService.instance);
  final _notesController = TextEditingController();

  List<_CheckoutGroup> _groups = const [];
  bool _loading = true;
  bool _placing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

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

    final items = (cart['items'] as List? ?? [])
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    if (items.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Your cart is empty.';
      });
      return;
    }

    final grouped = <int, List<Map<String, dynamic>>>{};
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
        itemIds: entry.value.map((e) => e['id'] as int).toList(),
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

      final options = (preview['options'] as List? ?? [])
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => Map<String, dynamic>.from(e))
          .where((o) => o['available'] == true)
          .toList();
      if (options.isEmpty) {
        setState(() {
          _loading = false;
          _error = 'No delivery options available.';
        });
        return;
      }

      final fulfillment =
          options.first['fulfillment_type']?.toString() ?? 'pickup';
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

  int? _resolveBranchId(Map<String, dynamic> item) {
    final direct = item['branch_id'];
    if (direct is int) return direct;
    if (direct is num) return direct.toInt();

    final product = Map<String, dynamic>.from(item['product'] as Map? ?? {});
    final branchIds = product['branch_ids'];
    if (branchIds is List && branchIds.isNotEmpty) {
      final first = branchIds.first;
      if (first is int) return first;
      if (first is num) return first.toInt();
    }
    return null;
  }

  void _setFulfillment(_CheckoutGroup group, String type) {
    setState(() {
      group.fulfillmentType = type;
      final methods = group.availablePaymentMethods();
      if (!methods.contains(group.paymentMethod)) {
        group.paymentMethod = methods.isEmpty ? '' : methods.first;
      }
    });
  }

  Future<void> _placeOrder() async {
    if (_placing || _groups.isEmpty) return;

    for (final group in _groups) {
      if (group.fulfillmentType.isEmpty || group.paymentMethod.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Choose delivery and payment for every store.'),
          ),
        );
        return;
      }
      if (isDeliveryFulfillment(group.fulfillmentType) &&
          ref.read(savedAddressesProvider).selectedAddress == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add a delivery address to continue.')),
        );
        return;
      }
    }

    final selectedAddress = ref.read(savedAddressesProvider).selectedAddress;
    final notes = _notesController.text.trim();
    final checkoutGroups = _groups.map((group) {
      final isDelivery = isDeliveryFulfillment(group.fulfillmentType);
      return {
        'branch_id': group.branchId,
        'item_ids': group.items.map((e) => e['id'] as int).toList(),
        'fulfillment_type': group.fulfillmentType,
        'payment_method': group.paymentMethod,
        'delivery_address_text': selectedAddress?.formattedAddress ?? '',
        'customer_notes': [
          if (isDelivery) selectedAddress?.deliveryInstructions.trim() ?? '',
          if (notes.isNotEmpty) notes,
        ].where((e) => e.isNotEmpty).join('\n'),
      };
    }).toList();

    setState(() => _placing = true);
    final placed = await _api.placeOrders(
      groups: checkoutGroups,
      addressId: selectedAddress?.id,
    );
    if (!mounted) return;
    setState(() => _placing = false);

    placed.fold(
      (f) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(f.message)),
      ),
      (orders) {
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final profile = ref.watch(userProfileProvider).profile;
    final address = ref.watch(savedAddressesProvider).selectedAddress;
    final canvas = homeCanvasOf(context);

    ref.listen(savedAddressesProvider, (previous, next) {
      if (!next.selectedLocationChangedFrom(previous)) return;
      _load();
    });

    return Scaffold(
      backgroundColor: canvas,
      appBar: AppBar(
        backgroundColor: canvas,
        title: const Text('Checkout'),
      ),
      bottomNavigationBar: _loading || _error != null || _groups.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Total',
                          style: tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Rs ${_money(_grandTotal)}',
                          style: tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _placing ? null : _placeOrder,
                        child: _placing
                            ? SizedBox(
                                width: 20.w,
                                height: 20.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: cs.onPrimary,
                                ),
                              )
                            : Text('Place order · Rs ${_money(_grandTotal)}'),
                      ),
                    ),
                  ],
                ),
              ),
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
                          onPressed: _load,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
                  children: [
                    _SectionCard(
                      title: 'Your details',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _DetailRow(
                            icon: Icons.person_outline_rounded,
                            label: profile.displayName,
                          ),
                          if (profile.phone != null &&
                              profile.phone!.trim().isNotEmpty) ...[
                            SizedBox(height: 8.h),
                            _DetailRow(
                              icon: Icons.phone_outlined,
                              label: profile.phone!,
                            ),
                          ],
                          if (profile.email.isNotEmpty) ...[
                            SizedBox(height: 8.h),
                            _DetailRow(
                              icon: Icons.mail_outline_rounded,
                              label: profile.email,
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _SectionCard(
                      title: 'Delivery address',
                      trailing: TextButton(
                        onPressed: () =>
                            showDeliveryAddressPicker(context, ref),
                        child: Text(address == null ? 'Add' : 'Change'),
                      ),
                      child: address == null
                          ? Text(
                              'Add an address for delivery orders.',
                              style: tt.bodyMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  address.shortLabel,
                                  style: tt.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: cs.onSurface,
                                  ),
                                ),
                                if (address.formattedAddress.isNotEmpty) ...[
                                  SizedBox(height: 4.h),
                                  Text(
                                    address.formattedAddress,
                                    style: tt.bodySmall?.copyWith(
                                      color: cs.onSurfaceVariant,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                                if (address.deliveryInstructions
                                    .trim()
                                    .isNotEmpty) ...[
                                  SizedBox(height: 8.h),
                                  Text(
                                    'Note: ${address.deliveryInstructions.trim()}',
                                    style: tt.bodySmall?.copyWith(
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                    ),
                    for (final group in _groups) ...[
                      SizedBox(height: 12.h),
                      _SectionCard(
                        title: group.storeName,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final item in group.items) ...[
                              _CheckoutItemRow(item: item),
                              if (item != group.items.last)
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(vertical: 10.h),
                                  child: Divider(
                                    height: 1,
                                    color: cs.outlineVariant,
                                  ),
                                ),
                            ],
                            SizedBox(height: 16.h),
                            Text(
                              'Fulfillment',
                              style: tt.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: cs.onSurface,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            for (final option in group.options)
                              _SelectableTile(
                                selected: group.fulfillmentType ==
                                    option['fulfillment_type']?.toString(),
                                title: (option['label']?.toString().trim().isNotEmpty ??
                                        false)
                                    ? option['label'].toString()
                                    : labelFulfillment(
                                        option['fulfillment_type']?.toString(),
                                      ),
                                subtitle:
                                    'Fee: Rs ${_money(_toDouble(option['fee']))}',
                                onTap: () => _setFulfillment(
                                  group,
                                  option['fulfillment_type']?.toString() ?? '',
                                ),
                              ),
                            SizedBox(height: 14.h),
                            Text(
                              'Payment method',
                              style: tt.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: cs.onSurface,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            for (final method
                                in group.availablePaymentMethods())
                              _SelectableTile(
                                selected: group.paymentMethod == method,
                                title: labelPayment(method),
                                subtitle: _paymentSubtitle(group, method),
                                onTap: () => setState(
                                  () => group.paymentMethod = method,
                                ),
                              ),
                            if (requiresPaymentProof(group.paymentMethod))
                              _PaymentInstructionsDetails(
                                method: group.paymentMethod,
                                payments: group.payments,
                              ),
                          ],
                        ),
                      ),
                    ],
                    SizedBox(height: 12.h),
                    _SectionCard(
                      title: 'Order notes',
                      child: TextField(
                        controller: _notesController,
                        minLines: 2,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Optional note for the store',
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _SectionCard(
                      title: 'Order summary',
                      child: Column(
                        children: [
                          _SummaryRow(
                            label: 'Items',
                            value: 'Rs ${_money(_itemsTotal)}',
                          ),
                          SizedBox(height: 8.h),
                          _SummaryRow(
                            label: 'Delivery fee',
                            value: 'Rs ${_money(_feesTotal)}',
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            child: Divider(
                              height: 1,
                              color: cs.outlineVariant,
                            ),
                          ),
                          _SummaryRow(
                            label: 'Total',
                            value: 'Rs ${_money(_grandTotal)}',
                            emphasize: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  String? _paymentSubtitle(_CheckoutGroup group, String method) {
    if (method == 'bank_transfer') {
      final iban = _bankField(group.payments, 'iban') ??
          _bankField(group.payments, 'account_iban');
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      color: cs.surfaceContainerLowest,
      borderRadius: AppBorders.card,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: AppBorders.card,
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Padding(
          padding: EdgeInsets.all(14.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
              SizedBox(height: 12.h),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: cs.onSurfaceVariant),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}

class _CheckoutItemRow extends StatelessWidget {
  const _CheckoutItemRow({required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final product = Map<String, dynamic>.from(item['product'] as Map? ?? {});
    final name = (product['name']?.toString().trim().isNotEmpty ?? false)
        ? product['name'].toString()
        : 'Product';
    final imageUrl = product['image_url']?.toString();
    final qty = item['quantity'] ?? 1;
    final lineTotal = item['line_total'] ?? product['effective_price'];

    return Row(
      children: [
        ClipRRect(
          borderRadius: AppBorders.sm,
          child: SizedBox(
            width: 56.w,
            height: 56.w,
            child: imageUrl != null && imageUrl.isNotEmpty
                ? Image.network(imageUrl, fit: BoxFit.cover)
                : ColoredBox(
                    color: cs.surfaceContainerHighest,
                    child: Icon(
                      Icons.image_outlined,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: tt.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Qty $qty',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
        Text(
          'Rs $lineTotal',
          style: tt.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: cs.onSurface,
          ),
        ),
      ],
    );
  }
}

class _SelectableTile extends StatelessWidget {
  const _SelectableTile({
    required this.selected,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final bool selected;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Material(
        color: selected
            ? cs.primary.withValues(alpha: 0.08)
            : cs.surfaceContainerHigh.withValues(alpha: 0.55),
        borderRadius: AppBorders.md,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppBorders.md,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            decoration: BoxDecoration(
              borderRadius: AppBorders.md,
              border: Border.all(
                color: selected ? cs.primary : cs.outlineVariant,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: selected ? cs.primary : cs.onSurfaceVariant,
                  size: 20,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                      if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                        SizedBox(height: 2.h),
                        Text(
                          subtitle!,
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentInstructionsDetails extends StatelessWidget {
  const _PaymentInstructionsDetails({
    required this.method,
    required this.payments,
  });

  final String method;
  final Map<String, dynamic> payments;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final title = switch (method) {
      'stripe' => 'Card payment details',
      'jazzcash' => 'JazzCash details',
      _ => 'Bank transfer details',
    };
    final instructions = _instructionsForMethod(payments, method);
    final iban = method == 'bank_transfer'
        ? (_bankField(payments, 'iban') ??
            _bankField(payments, 'account_iban') ??
            _bankField(payments, 'bank_transfer_iban'))
        : null;
    final accountName = method == 'bank_transfer'
        ? (_bankField(payments, 'account_name') ??
            _bankField(payments, 'bank_account_name'))
        : null;
    final bankName = method == 'bank_transfer'
        ? (_bankField(payments, 'bank_name') ?? _bankField(payments, 'bank'))
        : null;

    if (iban == null &&
        accountName == null &&
        bankName == null &&
        (instructions == null || instructions.isEmpty)) {
      return Padding(
        padding: EdgeInsets.only(top: 4.h, bottom: 4.h),
        child: Text(
          'After the shop accepts your order, pay and upload your transaction screenshot.',
          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant, height: 1.35),
        ),
      );
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 4.h, bottom: 4.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh.withValues(alpha: 0.7),
        borderRadius: AppBorders.md,
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: tt.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
          ),
          SizedBox(height: 8.h),
          if (bankName != null) _BankLine(label: 'Bank', value: bankName),
          if (accountName != null)
            _BankLine(label: 'Account name', value: accountName),
          if (iban != null) _BankLine(label: 'IBAN', value: iban),
          if (instructions != null && instructions.isNotEmpty) ...[
            if (iban != null || accountName != null || bankName != null)
              SizedBox(height: 6.h),
            Text(
              instructions,
              style: tt.bodySmall?.copyWith(
                color: cs.onSurface,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BankLine extends StatelessWidget {
  const _BankLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96.w,
            child: Text(
              label,
              style: tt.labelMedium?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: tt.bodyMedium?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Row(
      children: [
        Text(
          label,
          style: (emphasize ? tt.titleSmall : tt.bodyMedium)?.copyWith(
            fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: (emphasize ? tt.titleSmall : tt.bodyMedium)?.copyWith(
            fontWeight: FontWeight.w800,
            color: cs.onSurface,
          ),
        ),
      ],
    );
  }
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

String _money(double value) => value.toStringAsFixed(2);

String? _bankField(Map<String, dynamic> payments, String key) {
  final direct = payments[key] ?? payments['bank_transfer_$key'];
  if (direct != null && direct.toString().trim().isNotEmpty) {
    return direct.toString().trim();
  }
  final nested = payments['bank_transfer_details'];
  if (nested is Map) {
    final value = nested[key] ?? nested['bank_transfer_$key'];
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString().trim();
    }
  }
  final instructions = payments['bank_transfer_instructions'];
  if (instructions is Map) {
    final value = instructions[key];
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString().trim();
    }
  }
  return null;
}

String? _instructionsForMethod(Map<String, dynamic> payments, String method) {
  final key = switch (method) {
    'stripe' => 'stripe_instructions',
    'jazzcash' => 'jazzcash_instructions',
    _ => 'bank_transfer_instructions',
  };
  final raw = payments[key];
  if (raw is String && raw.trim().isNotEmpty) return raw.trim();
  if (raw is Map) {
    final text = raw['text'] ?? raw['instructions'] ?? raw['message'];
    if (text != null && text.toString().trim().isNotEmpty) {
      return text.toString().trim();
    }
  }
  return null;
}
