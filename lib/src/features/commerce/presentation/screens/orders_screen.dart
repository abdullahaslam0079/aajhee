import 'package:aajhee/src/features/commerce/data/commerce_api_service.dart';
import 'package:aajhee/src/features/commerce/domain/commerce_labels.dart';
import 'package:aajhee/src/features/commerce/presentation/widgets/rate_product_sheet.dart';
import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _api = CommerceApiService(DioService.instance);
  List<Map<String, dynamic>> _orders = const [];
  bool _loading = true;
  String? _error;
  OrderStatusGroup _statusGroup = OrderStatusGroup.active;

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
    final result = await _api.getOrders(
      statusGroup: _statusGroup.apiValue,
    );
    if (!mounted) return;
    result.fold(
      (f) => setState(() {
        _loading = false;
        _error = f.message;
      }),
      (items) => setState(() {
        _orders = items;
        _loading = false;
      }),
    );
  }

  void _selectGroup(OrderStatusGroup group) {
    if (group == _statusGroup) return;
    setState(() => _statusGroup = group);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final canvas = homeCanvasOf(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: canvas,
      appBar: AppBar(
        backgroundColor: canvas,
        title: const Text('My orders'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
            child: SizedBox(
              height: 36.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: OrderStatusGroup.values.length,
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
                itemBuilder: (context, index) {
                  final group = OrderStatusGroup.values[index];
                  final selected = group == _statusGroup;
                  final bg = selected
                      ? cs.primary
                      : cs.surfaceContainerLowest;
                  final fg =
                      selected ? cs.onPrimary : cs.onSurfaceVariant;
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _selectGroup(group),
                      borderRadius: AppBorders.md,
                      child: Ink(
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: AppBorders.md,
                          border: selected
                              ? null
                              : Border.all(color: cs.outlineVariant),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14.w),
                          child: Center(
                            child: Text(
                              group.label,
                              style: tt.labelMedium?.copyWith(
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: fg,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: _loading
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
                    : _orders.isEmpty
                        ? AppEmptyState(
                            icon: Icons.receipt_long_outlined,
                            title: 'No ${_statusGroup.label.toLowerCase()} orders',
                            subtitle:
                                'When you place an order, it will show up here.',
                            actionLabel: 'Continue shopping',
                            onAction: () => context.pop(),
                          )
                        : RefreshIndicator(
                            onRefresh: _load,
                            child: ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              padding:
                                  EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                              itemCount: _orders.length,
                              separatorBuilder: (_, __) =>
                                  SizedBox(height: 12.h),
                              itemBuilder: (context, index) {
                                final order = _orders[index];
                                return _OrderListCard(
                                  order: order,
                                  onTap: () async {
                                    await context.push(
                                      AppRoutes.orderDetail(
                                        order['public_id'].toString(),
                                      ),
                                    );
                                    if (mounted) _load();
                                  },
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class _OrderListCard extends StatelessWidget {
  const _OrderListCard({
    required this.order,
    required this.onTap,
  });

  final Map<String, dynamic> order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final status = order['status']?.toString();
    final (statusColor, statusBg) = _statusColors(context, status);
    final items = (order['items'] as List? ?? const []);
    final itemCount = items.fold<int>(0, (sum, item) {
      if (item is! Map) return sum + 1;
      final qty = item['quantity'];
      if (qty is int) return sum + qty;
      if (qty is num) return sum + qty.toInt();
      return sum + 1;
    });
    final firstName = items.isNotEmpty && items.first is Map
        ? (items.first as Map)['product_name']?.toString()
        : null;
    final itemSummary = itemCount <= 0
        ? 'No items'
        : itemCount == 1
            ? ((firstName?.isNotEmpty ?? false) ? firstName! : '1 item')
            : (firstName?.isNotEmpty ?? false)
                ? '$firstName + ${itemCount - 1} more'
                : '$itemCount items';
    final placedAt = formatCommerceDateTime(order['placed_at']?.toString());
    final orderNumber = formatOrderNumber(order['public_id']?.toString());

    return Material(
      color: cs.surfaceContainerLowest,
      borderRadius: AppBorders.card,
      child: InkWell(
        onTap: onTap,
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
                        order['business_name']?.toString() ?? 'Order',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                    Text(
                      'Rs ${order['total']}',
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Text(
                  itemSummary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.75),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: AppBorders.sm,
                      ),
                      child: Text(
                        labelStatus(status),
                        style: tt.labelMedium?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        [
                          labelFulfillment(
                            order['fulfillment_type']?.toString(),
                          ),
                          labelPayment(order['payment_method']?.toString()),
                        ].join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: cs.onSurfaceVariant,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        placedAt == '—' ? 'Recently placed' : placedAt,
                        style: tt.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (orderNumber.isNotEmpty)
                      Text(
                        orderNumber,
                        style: tt.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: cs.primary,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key, required this.publicId});

  final String publicId;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final _api = CommerceApiService(DioService.instance);
  Map<String, dynamic>? _order;
  final Map<int, String> _productImages = {};
  bool _loading = true;
  bool _cancelling = false;
  bool _reporting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await _api.getOrder(widget.publicId);
    if (!mounted) return;
    await result.fold(
      (f) async {
        setState(() {
          _loading = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(f.message)),
          );
        });
      },
      (order) async {
        setState(() {
          _order = order;
          _loading = false;
        });
        await _loadProductImages(order);
      },
    );
  }

  Future<void> _loadProductImages(Map<String, dynamic> order) async {
    final items = ((order['items'] as List?) ?? const [])
        .whereType<Map<dynamic, dynamic>>()
        .map((i) => Map<String, dynamic>.from(i));

    final pendingIds = <int>{};
    for (final item in items) {
      final embedded = _imageFromItem(item);
      final productId = _asInt(item['product_id']);
      if (embedded != null && productId != null) {
        _productImages[productId] = embedded;
        continue;
      }
      if (productId != null && !_productImages.containsKey(productId)) {
        pendingIds.add(productId);
      }
    }
    if (pendingIds.isEmpty) {
      if (mounted) setState(() {});
      return;
    }

    await Future.wait(pendingIds.map((id) async {
      final result = await _api.getProduct(id);
      result.fold((_) {}, (product) {
        final url = product['image_url']?.toString().trim();
        if (url != null && url.isNotEmpty) {
          _productImages[id] = url;
        }
      });
    }));
    if (mounted) setState(() {});
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static String? _imageFromItem(Map<String, dynamic> item) {
    for (final key in [
      'image_url',
      'product_image_url',
      'thumbnail_url',
      'product_image',
    ]) {
      final value = item[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    final product = item['product'];
    if (product is Map) {
      final value = product['image_url']?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  Future<void> _cancelOrder() async {
    final reasonController = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cancel order?'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'You can only cancel while the shop has not accepted yet.',
                ),
                SizedBox(height: 12.h),
                TextField(
                  controller: reasonController,
                  autofocus: true,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Reason',
                    hintText: 'Why are you cancelling?',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Keep order'),
            ),
            FilledButton(
              onPressed: () {
                final text = reasonController.text.trim();
                if (text.isEmpty) return;
                Navigator.pop(dialogContext, text);
              },
              child: const Text('Cancel order'),
            ),
          ],
        );
      },
    );
    reasonController.dispose();
    if (reason == null || reason.isEmpty) return;

    setState(() => _cancelling = true);
    final result = await _api.cancelOrder(
      widget.publicId,
      reason: reason,
    );
    if (!mounted) return;
    result.fold(
      (f) {
        setState(() => _cancelling = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(f.message)),
        );
      },
      (_) {
        setState(() => _cancelling = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order cancelled')),
        );
        _load();
      },
    );
  }

  Future<void> _contactStore() async {
    final order = _order;
    if (order == null) return;
    final raw = (order['store_whatsapp'] ?? order['store_phone'] ?? '')
        .toString()
        .trim();
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No store contact available')),
      );
      return;
    }
    final result = await UrlLauncherService.instance.launch(digits);
    if (!mounted) return;
    result.fold(
      (f) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(f.message)),
      ),
      (_) {},
    );
  }

  Future<void> _reportProblem() async {
    final messageController = TextEditingController();
    final message = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Report a problem'),
          content: TextField(
            controller: messageController,
            autofocus: true,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'What went wrong?',
              hintText: 'Describe the issue',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final text = messageController.text.trim();
                if (text.isEmpty) return;
                Navigator.pop(dialogContext, text);
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
    messageController.dispose();
    if (message == null || message.isEmpty) return;

    setState(() => _reporting = true);
    final result = await _api.reportOrderProblem(
      publicId: widget.publicId,
      message: message,
    );
    if (!mounted) return;
    setState(() => _reporting = false);
    result.fold(
      (f) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(f.message)),
      ),
      (_) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Problem reported')),
      ),
    );
  }

  Future<void> _uploadProof() async {
    final colors = Theme.of(context).colorScheme;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final labelStyle = Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
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

    // Let the sheet finish dismissing before presenting the native picker.
    // Calling pickImage mid-transition often fails on iOS with a channel-error.
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;

    late final XFile picked;
    try {
      final result = await ImagePicker().pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 2000,
        requestFullMetadata: false,
      );
      if (result == null || !mounted) return;
      picked = result;
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
      return;
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the photo picker.')),
      );
      return;
    }

    final note = await showDialog<String>(
      context: context,
      builder: (dialogContext) => _PaymentProofNoteDialog(
        fileName: picked.name,
      ),
    );
    if (note == null || !mounted) return;

    final multipart = await MultipartFile.fromFile(
      picked.path,
      filename: picked.name,
    );
    final result = await _api.uploadPaymentProof(
      publicId: widget.publicId,
      file: multipart,
      note: note,
    );
    if (!mounted) return;
    result.fold(
      (f) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(f.message)),
      ),
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment proof submitted')),
        );
        _load();
      },
    );
  }

  static String _text(Map<String, dynamic> order, String key) =>
      (order[key] ?? '').toString().trim();

  static bool _hasFee(String fee) {
    if (fee.isEmpty) return false;
    final parsed = double.tryParse(fee);
    return parsed == null ? true : parsed > 0;
  }

  String _pendingCancelBlockedReason(Map<String, dynamic> order) {
    if (order['customer_cancel_allowed'] == false) {
      return 'This shop does not allow customers to cancel orders. '
          'Contact the shop if you need help.';
    }
    final until = DateTime.tryParse(_text(order, 'customer_cancel_until'));
    if (until != null && DateTime.now().isAfter(until)) {
      return 'The cancellation window closed at '
          '${formatCommerceDateTime(_text(order, 'customer_cancel_until'))}. '
          'Contact the shop if you need help.';
    }
    return 'This order can no longer be cancelled. '
        'Contact the shop if you need help.';
  }

  @override
  Widget build(BuildContext context) {
    final order = _order;
    final canvas = homeCanvasOf(context);
    return Scaffold(
      backgroundColor: canvas,
      appBar: AppBar(
        backgroundColor: canvas,
        title: const Text('Order details'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : order == null
              ? AppEmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'Order not found',
                  subtitle: 'This order may have been removed.',
                  actionLabel: 'Back to orders',
                  onAction: () => context.pop(),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: _buildDetail(context, order),
                ),
    );
  }

  Widget _buildDetail(BuildContext context, Map<String, dynamic> order) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final status = _text(order, 'status');
    final fulfillment = _text(order, 'fulfillment_type');
    final paymentMethod = _text(order, 'payment_method');
    final paymentStatus = _text(order, 'payment_status');
    final customerPhone = _text(order, 'customer_phone');
    final isPickup = isPickupFulfillment(fulfillment);
    final branchName = _text(order, 'branch_name');
    final customerNotes = _text(order, 'customer_notes');
    final deliveryFee = _text(order, 'delivery_fee');
    final addressText = _text(order, 'delivery_address_text');
    final houseNumber = _text(order, 'delivery_house_number');
    final landmark = _text(order, 'delivery_landmark');
    final bankInstructions = _text(order, 'payment_instructions').isNotEmpty
        ? _text(order, 'payment_instructions')
        : _text(order, 'bank_transfer_instructions');
    final placedAt = formatCommerceDateTime(_text(order, 'placed_at'));
    final orderNumber = formatOrderNumber(_text(order, 'public_id'));
    final (statusColor, statusBg) = _statusColors(context, status);
    final items = ((order['items'] as List?) ?? const [])
        .whereType<Map<dynamic, dynamic>>()
        .map((i) => Map<String, dynamic>.from(i))
        .toList();
    final proofs = ((order['payment_proofs'] as List?) ?? const [])
        .whereType<Map<dynamic, dynamic>>()
        .map((p) => Map<String, dynamic>.from(p))
        .toList();
    final canUploadProof = requiresPaymentProof(paymentMethod) &&
        (status == 'awaiting_payment' ||
            status == 'accepted' ||
            status == 'payment_submitted');
    final timelineIndex = orderTimelineIndex(
      status,
      fulfillmentType: fulfillment,
    );
    final addressParts = [
      if (houseNumber.isNotEmpty) houseNumber,
      if (landmark.isNotEmpty) landmark,
      if (addressText.isNotEmpty) addressText,
    ];

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 28.h),
      children: [
        _SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: AppBorders.sm,
                ),
                child: Text(
                  labelStatus(status),
                  style: tt.titleSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                order['business_name']?.toString() ?? 'Store',
                style: tt.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),
              if (branchName.isNotEmpty) ...[
                SizedBox(height: 4.h),
                Text(
                  branchName,
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              SizedBox(height: 10.h),
              _MetaLine(
                icon: Icons.tag_rounded,
                label: orderNumber.isEmpty
                    ? 'Order'
                    : 'Order $orderNumber',
              ),
              if (placedAt != '—') ...[
                SizedBox(height: 6.h),
                _MetaLine(
                  icon: Icons.schedule_rounded,
                  label: 'Placed $placedAt',
                ),
              ],
            ],
          ),
        ),
        if (timelineIndex >= 0) ...[
          SizedBox(height: 12.h),
          _SectionCard(
            title: 'Status',
            child: _OrderTimeline(
              fulfillmentType: fulfillment,
              currentIndex: timelineIndex,
            ),
          ),
        ],
        SizedBox(height: 12.h),
        _SectionCard(
          title: isPickup ? 'Pickup' : 'Delivery',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoRow(
                label: 'Method',
                value: labelFulfillment(fulfillment),
              ),
              if (fulfillment == 'local_same_day') ...[
                SizedBox(height: 10.h),
                _InfoRow(
                  label: 'Promised by',
                  value: () {
                    final snap = order['delivery_snapshot'];
                    final promised = snap is Map
                        ? formatCommerceDateTime(
                            snap['promised_by']?.toString(),
                          )
                        : '—';
                    if (promised == '—' || promised.isEmpty) {
                      return 'End of day';
                    }
                    return 'End of day · $promised';
                  }(),
                ),
              ],
              if (!isPickup && addressParts.isNotEmpty) ...[
                SizedBox(height: 10.h),
                _InfoRow(
                  label: 'Address',
                  value: addressParts.join('\n'),
                  multiline: true,
                ),
              ],
              if (isPickup && branchName.isNotEmpty) ...[
                SizedBox(height: 10.h),
                _InfoRow(
                  label: 'Pickup from',
                  value: branchName,
                ),
              ],
              if (customerPhone.isNotEmpty) ...[
                SizedBox(height: 10.h),
                _InfoRow(
                  label: 'Phone',
                  value: customerPhone,
                ),
              ],
              if (customerNotes.isNotEmpty) ...[
                SizedBox(height: 10.h),
                _InfoRow(
                  label: 'Your notes',
                  value: customerNotes,
                  multiline: true,
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 12.h),
        _SectionCard(
          title: 'Payment',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoRow(
                label: 'Method',
                value: labelPayment(paymentMethod),
              ),
              if (paymentStatus.isNotEmpty) ...[
                SizedBox(height: 10.h),
                _InfoRow(
                  label: 'Status',
                  value: labelPaymentStatus(paymentStatus),
                ),
              ],
              if (bankInstructions.isNotEmpty) ...[
                SizedBox(height: 12.h),
                Container(
                  width: double.infinity,
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
                        switch (paymentMethod) {
                          'stripe' => 'Card payment details',
                          'jazzcash' => 'JazzCash details',
                          _ => 'Bank transfer details',
                        },
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        bankInstructions,
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onSurface,
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 12.h),
        _SectionCard(
          title: items.length == 1 ? '1 item' : '${items.length} items',
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                _OrderItemTile(
                  item: items[i],
                  imageUrl: _productImages[_asInt(items[i]['product_id'])] ??
                      _imageFromItem(items[i]),
                  orderStatus: status,
                  onRate: status == 'completed' &&
                          (items[i]['can_review'] == true)
                      ? () async {
                          final ok = await showRateProductSheet(
                            context: context,
                            api: _api,
                            orderPublicId: widget.publicId,
                            item: items[i],
                          );
                          if (ok && mounted) _load();
                        }
                      : null,
                ),
                if (i != items.length - 1)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    child: Divider(height: 1, color: cs.outlineVariant),
                  ),
              ],
            ],
          ),
        ),
        SizedBox(height: 12.h),
        _SectionCard(
          title: 'Order summary',
          child: Column(
            children: [
              _SummaryRow(
                label: 'Subtotal',
                value: 'Rs ${order['subtotal']}',
              ),
              if (_hasFee(deliveryFee)) ...[
                SizedBox(height: 8.h),
                _SummaryRow(
                  label: 'Delivery fee',
                  value: 'Rs $deliveryFee',
                ),
              ],
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                child: Divider(height: 1, color: cs.outlineVariant),
              ),
              _SummaryRow(
                label: 'Total',
                value: 'Rs ${order['total']}',
                emphasize: true,
              ),
            ],
          ),
        ),
        if (status == 'cancelled') ...[
          SizedBox(height: 12.h),
          _CancelledInfoCard(order: order),
        ],
        if (proofs.isNotEmpty) ...[
          SizedBox(height: 12.h),
          _SectionCard(
            title: 'Payment receipts',
            child: Column(
              children: [
                for (var i = 0; i < proofs.length; i++) ...[
                  _PaymentProofTile(proof: proofs[i]),
                  if (i != proofs.length - 1) SizedBox(height: 10.h),
                ],
              ],
            ),
          ),
        ],
        SizedBox(height: 16.h),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _contactStore,
            icon: const Icon(Icons.chat_outlined),
            label: const Text('Contact store'),
          ),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _reporting ? null : _reportProblem,
            icon: const Icon(Icons.flag_outlined),
            label: Text(_reporting ? 'Reporting…' : 'Report a problem'),
          ),
        ),
        SizedBox(height: 8.h),
        _CancelSection(
          order: order,
          cancelling: _cancelling,
          onCancel: _cancelOrder,
          pendingBlockedReason: _pendingCancelBlockedReason(order),
        ),
        if (canUploadProof) ...[
          SizedBox(height: 8.h),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _uploadProof,
              child: const Text('Upload payment receipt'),
            ),
          ),
        ],
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.child,
    this.title,
  });

  final String? title;
  final Widget child;

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
              if (title != null) ...[
                Text(
                  title!,
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
                SizedBox(height: 12.h),
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderTimeline extends StatelessWidget {
  const _OrderTimeline({
    required this.fulfillmentType,
    required this.currentIndex,
  });

  final String fulfillmentType;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final steps = orderTimelineSteps(fulfillmentType: fulfillmentType);

    return Column(
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 22.w,
                    height: 22.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i <= currentIndex
                          ? cs.primary
                          : cs.surfaceContainerHighest,
                      border: Border.all(
                        color: i <= currentIndex
                            ? cs.primary
                            : cs.outlineVariant,
                        width: 1.5,
                      ),
                    ),
                    child: i < currentIndex
                        ? Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: cs.onPrimary,
                          )
                        : i == currentIndex
                            ? Center(
                                child: Container(
                                  width: 8.w,
                                  height: 8.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: cs.onPrimary,
                                  ),
                                ),
                              )
                            : null,
                  ),
                  if (i != steps.length - 1)
                    Container(
                      width: 2,
                      height: 22.h,
                      color: i < currentIndex
                          ? cs.primary
                          : cs.outlineVariant,
                    ),
                ],
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 2.h, bottom: 8.h),
                  child: Text(
                    steps[i].label,
                    style: tt.bodyMedium?.copyWith(
                      fontWeight: i <= currentIndex
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: i <= currentIndex
                          ? cs.primary
                          : cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: cs.onSurfaceVariant),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.multiline = false,
  });

  final String label;
  final String value;
  final bool multiline;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    if (multiline) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: tt.labelMedium?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: tt.bodyMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100.w,
          child: Text(
            label,
            style: tt.labelMedium?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w700,
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
    );
  }
}

class _OrderItemTile extends StatelessWidget {
  const _OrderItemTile({
    required this.item,
    this.imageUrl,
    this.orderStatus,
    this.onRate,
  });

  final Map<String, dynamic> item;
  final String? imageUrl;
  final String? orderStatus;
  final VoidCallback? onRate;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final name = (item['product_name']?.toString().trim().isNotEmpty ?? false)
        ? item['product_name'].toString()
        : 'Product';
    final qty = item['quantity'] ?? 1;
    final lineTotal = item['line_total'];
    final productId = item['product_id'];
    final initial = name.isNotEmpty ? name.characters.first.toUpperCase() : '?';
    final resolvedImage = (imageUrl ?? '').trim();
    final review = item['review'] is Map
        ? Map<String, dynamic>.from(item['review'] as Map)
        : null;
    final reviewRating = review == null
        ? null
        : int.tryParse('${review['rating'] ?? ''}');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: productId == null
            ? null
            : () => context.push(
                  AppRoutes.productDetail('$productId'),
                ),
        borderRadius: AppBorders.md,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 2.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: AppBorders.md,
                child: SizedBox(
                  width: 56.w,
                  height: 56.w,
                  child: resolvedImage.isNotEmpty
                      ? Image.network(
                          resolvedImage,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _ItemImageFallback(
                            initial: initial,
                            colorScheme: cs,
                            textTheme: tt,
                          ),
                        )
                      : _ItemImageFallback(
                          initial: initial,
                          colorScheme: cs,
                          textTheme: tt,
                        ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Qty $qty · Rs $lineTotal',
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.72),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (reviewRating != null) ...[
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          ...List.generate(
                            5,
                            (i) => Icon(
                              i < reviewRating
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              size: 16.sp,
                              color: const Color(0xFFE6A817),
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'Your rating',
                            style: tt.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ] else if (onRate != null) ...[
                      SizedBox(height: 8.h),
                      OutlinedButton.icon(
                        onPressed: onRate,
                        icon: Icon(Icons.star_outline_rounded, size: 18.sp),
                        label: const Text('Rate product'),
                        style: OutlinedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                        ),
                      ),
                    ] else if (productId != null) ...[
                      SizedBox(height: 4.h),
                      Text(
                        'View product',
                        style: tt.labelMedium?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (productId != null)
                Icon(Icons.chevron_right_rounded, color: cs.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemImageFallback extends StatelessWidget {
  const _ItemImageFallback({
    required this.initial,
    required this.colorScheme,
    required this.textTheme,
  });

  final String initial;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: colorScheme.primary.withValues(alpha: 0.1),
      child: Center(
        child: Text(
          initial,
          style: textTheme.titleMedium?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
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

class _PaymentProofNoteDialog extends StatefulWidget {
  const _PaymentProofNoteDialog({required this.fileName});

  final String fileName;

  @override
  State<_PaymentProofNoteDialog> createState() =>
      _PaymentProofNoteDialogState();
}

class _PaymentProofNoteDialogState extends State<_PaymentProofNoteDialog> {
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return AlertDialog(
      title: const Text('Payment receipt'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.fileName, style: tt.bodySmall),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Transaction reference / note (optional)',
              ),
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _noteController.text),
          child: const Text('Upload'),
        ),
      ],
    );
  }
}

class _CancelledInfoCard extends StatelessWidget {
  const _CancelledInfoCard({required this.order});

  final Map<String, dynamic> order;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final by = (order['cancelled_by'] ?? '').toString().trim();
    final reason = (order['cancel_reason'] ?? '').toString().trim();
    final at = (order['cancelled_at'] ?? '').toString().trim();
    final lines = <String>[
      if (by.isNotEmpty) 'Cancelled by ${labelCancelledBy(by)}',
      if (at.isNotEmpty) 'On ${formatCommerceDateTime(at)}',
      if (reason.isNotEmpty) 'Reason: $reason',
    ];
    if (lines.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: cs.errorContainer.withValues(alpha: 0.45),
        borderRadius: AppBorders.card,
        border: Border.all(color: cs.error.withValues(alpha: 0.25)),
      ),
      child: Text(
        lines.join('\n'),
        style: tt.bodyMedium?.copyWith(
          color: cs.onErrorContainer,
          fontWeight: FontWeight.w600,
          height: 1.35,
        ),
      ),
    );
  }
}

class _PaymentProofTile extends StatelessWidget {
  const _PaymentProofTile({required this.proof});

  final Map<String, dynamic> proof;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final status = (proof['review_status'] ?? '').toString();
    final note = (proof['note'] ?? '').toString().trim();
    final reviewNote = (proof['review_note'] ?? '').toString().trim();
    final submittedAt = (proof['submitted_at'] ?? '').toString().trim();
    final fileUrl = resolveMediaUrl(proof['file_url']?.toString());
    final statusColor = switch (status) {
      'accepted' => context.appColors.success,
      'rejected' => cs.error,
      _ => cs.onSurfaceVariant,
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          onPressed: fileUrl == null
              ? null
              : () => launchUrl(
                    Uri.parse(fileUrl),
                    mode: LaunchMode.externalApplication,
                  ),
          icon: Icon(Icons.receipt_long_outlined, color: cs.primary),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                labelPaymentProofReview(status),
                style: tt.titleSmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (submittedAt.isNotEmpty)
                Text(
                  'Submitted ${formatCommerceDateTime(submittedAt)}',
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (note.isNotEmpty)
                Text(
                  'Note: $note',
                  style: tt.bodySmall?.copyWith(color: cs.onSurface),
                ),
              if (reviewNote.isNotEmpty)
                Text(
                  'Shop: $reviewNote',
                  style: tt.bodySmall?.copyWith(color: cs.onSurface),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CancelSection extends StatelessWidget {
  const _CancelSection({
    required this.order,
    required this.cancelling,
    required this.onCancel,
    required this.pendingBlockedReason,
  });

  final Map<String, dynamic> order;
  final bool cancelling;
  final VoidCallback onCancel;
  final String pendingBlockedReason;

  @override
  Widget build(BuildContext context) {
    final status = (order['status'] ?? '').toString();
    final canCancel = order['can_customer_cancel'] == true;
    final small = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        );

    if (canCancel) {
      final until = (order['customer_cancel_until'] ?? '').toString().trim();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton(
            onPressed: cancelling ? null : onCancel,
            child: Text(cancelling ? 'Cancelling…' : 'Cancel order'),
          ),
          if (until.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 6.h),
              child: Text(
                'Cancel until ${formatCommerceDateTime(until)}',
                textAlign: TextAlign.center,
                style: small,
              ),
            ),
        ],
      );
    }

    if (status == 'pending') {
      return Text(pendingBlockedReason, style: small);
    }
    if (status == 'cancelled' || status == 'completed') {
      return const SizedBox.shrink();
    }
    return Text(
      'This order can no longer be cancelled. Contact the shop if you need help.',
      style: small,
    );
  }
}

(Color, Color) _statusColors(BuildContext context, String? status) {
  final cs = Theme.of(context).colorScheme;
  final appColors = context.appColors;
  return switch (status) {
    'completed' => (
        appColors.success,
        appColors.successContainer ??
            appColors.success.withValues(alpha: 0.12),
      ),
    'cancelled' => (cs.error, cs.errorContainer),
    'pending' ||
    'accepted' ||
    'awaiting_payment' ||
    'payment_submitted' ||
    'paid_confirmed' ||
    'preparing' ||
    'ready_for_pickup' ||
    'out_for_delivery' => (
        appColors.warning,
        appColors.warningContainer ??
            appColors.warning.withValues(alpha: 0.12),
      ),
    _ => (cs.onSurfaceVariant, cs.surfaceContainerHighest),
  };
}
