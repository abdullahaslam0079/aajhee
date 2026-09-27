import 'package:aajhee/src/features/commerce/data/commerce_api_service.dart';
import 'package:aajhee/src/features/commerce/domain/commerce_labels.dart';
import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';
import 'package:aajhee/src/routing/app_routes.dart';
import 'package:aajhee/src/services/dio_service.dart';
import 'package:dio/dio.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _api = CommerceApiService(DioService.instance);
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    final result = await _api.getOrders();
    return result.fold((f) => throw Exception(f.message), (items) => items);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My orders')),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('No orders yet'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final o = items[index];
              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color:
                        Theme.of(context).dividerColor.withValues(alpha: 0.4),
                  ),
                ),
                title: Text('${o['business_name']} · Rs ${o['total']}'),
                subtitle: Text(
                  '${labelStatus(o['status']?.toString())} · ${labelFulfillment(o['fulfillment_type']?.toString())}',
                ),
                onTap: () => context.push(
                  AppRoutes.orderDetail(o['public_id'].toString()),
                ),
              );
            },
          );
        },
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
  bool _loading = true;
  bool _cancelling = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await _api.getOrder(widget.publicId);
    if (!mounted) return;
    result.fold(
      (f) => setState(() {
        _loading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(f.message)),
        );
      }),
      (order) => setState(() {
        _order = order;
        _loading = false;
      }),
    );
  }

  Future<void> _cancelOrder() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel order?'),
        content: const Text(
          'You can only cancel while the shop has not accepted yet.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep order'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancel order'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _cancelling = true);
    final result = await _api.cancelOrder(widget.publicId);
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

  Future<void> _uploadProof() async {
    final noteController = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment receipt'),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(
            labelText: 'Transaction reference / note',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, noteController.text),
            child: const Text('Submit note'),
          ),
        ],
      ),
    );
    if (note == null) return;
    // Minimal placeholder image bytes for receipt note submission until image_picker is added.
    final multipart = MultipartFile.fromBytes(
      List<int>.generate(16, (i) => i),
      filename: 'receipt-note.txt',
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

  /// Short explanation for why a pending order cannot be cancelled by the
  /// customer. Mirrors `customer_can_cancel` in the backend.
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

  Widget _cancelSection(BuildContext context, Map<String, dynamic> order) {
    final status = _text(order, 'status');
    final canCancel = order['can_customer_cancel'] == true;
    final small = Theme.of(context).textTheme.bodySmall;

    if (canCancel) {
      final until = _text(order, 'customer_cancel_until');
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton(
            onPressed: _cancelling ? null : _cancelOrder,
            child: Text(_cancelling ? 'Cancelling…' : 'Cancel order'),
          ),
          if (until.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
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
      return Text(_pendingCancelBlockedReason(order), style: small);
    }
    if (status == 'cancelled' || status == 'completed') {
      return const SizedBox.shrink();
    }
    return Text(
      'This order can no longer be cancelled. Contact the shop if you need help.',
      style: small,
    );
  }

  Widget _cancelledInfo(BuildContext context, Map<String, dynamic> order) {
    final by = _text(order, 'cancelled_by');
    final reason = _text(order, 'cancel_reason');
    final at = _text(order, 'cancelled_at');
    final scheme = Theme.of(context).colorScheme;
    final lines = <String>[
      if (by.isNotEmpty) 'Cancelled by: ${labelCancelledBy(by)}',
      if (at.isNotEmpty) 'Cancelled on: ${formatCommerceDateTime(at)}',
      if (reason.isNotEmpty) 'Reason: $reason',
    ];
    if (lines.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.errorContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(lines.join('\n')),
    );
  }

  Widget _paymentProofs(
      BuildContext context, List<Map<String, dynamic>> proofs) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text('Payment receipts', style: theme.textTheme.titleMedium),
        ...proofs.map((p) {
          final status = _text(p, 'review_status');
          final note = _text(p, 'note');
          final reviewNote = _text(p, 'review_note');
          final submittedAt = _text(p, 'submitted_at');
          final fileUrl = resolveMediaUrl(p['file_url']?.toString());
          final Color statusColor = switch (status) {
            'accepted' => Colors.green,
            'rejected' => theme.colorScheme.error,
            _ => theme.colorScheme.onSurfaceVariant,
          };
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: fileUrl != null
                ? IconButton(
                    icon: const Icon(Icons.receipt_long_outlined),
                    tooltip: 'Open receipt',
                    onPressed: () => launchUrl(
                      Uri.parse(fileUrl),
                      mode: LaunchMode.externalApplication,
                    ),
                  )
                : const Icon(Icons.receipt_long_outlined),
            title: Text(
              labelPaymentProofReview(status),
              style: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              [
                if (submittedAt.isNotEmpty)
                  'Submitted ${formatCommerceDateTime(submittedAt)}',
                if (note.isNotEmpty) 'Note: $note',
                if (reviewNote.isNotEmpty) 'Shop: $reviewNote',
              ].join('\n'),
            ),
            isThreeLine: note.isNotEmpty || reviewNote.isNotEmpty,
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = _order;
    return Scaffold(
      appBar: AppBar(title: const Text('Order')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : order == null
              ? const Center(child: Text('Not found'))
              : _buildDetail(context, order),
    );
  }

  Widget _buildDetail(BuildContext context, Map<String, dynamic> order) {
    final status = _text(order, 'status');
    final fulfillment = _text(order, 'fulfillment_type');
    final paymentMethod = _text(order, 'payment_method');
    final isPickup = isPickupFulfillment(fulfillment);
    final branchName = _text(order, 'branch_name');
    final customerNotes = _text(order, 'customer_notes');
    final deliveryFee = _text(order, 'delivery_fee');
    final addressText = _text(order, 'delivery_address_text');
    final bankInstructions = _text(order, 'bank_transfer_instructions');
    final proofs = ((order['payment_proofs'] as List?) ?? const [])
        .whereType<Map<dynamic, dynamic>>()
        .map((p) => Map<String, dynamic>.from(p))
        .toList();
    final canUploadProof = paymentMethod == 'bank_transfer' &&
        (status == 'awaiting_payment' ||
            status == 'accepted' ||
            status == 'payment_submitted');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          labelStatus(status),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        if (branchName.isNotEmpty)
          Text('${order['business_name']} · $branchName')
        else
          Text('${order['business_name']}'),
        const SizedBox(height: 8),
        Text('Fulfillment: ${labelFulfillment(fulfillment)}'),
        Text('Payment: ${labelPayment(paymentMethod)}'),
        if (_hasFee(deliveryFee))
          Text(
              'Subtotal: Rs ${order['subtotal']} · Delivery fee: Rs $deliveryFee'),
        Text('Total: Rs ${order['total']}'),
        if (!isPickup && addressText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('Deliver to:\n$addressText'),
          ),
        if (isPickup && branchName.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('Pick up from: $branchName'),
          ),
        if (customerNotes.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('Your notes:\n$customerNotes'),
          ),
        if (bankInstructions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('Bank details:\n$bankInstructions'),
          ),
        if (status == 'cancelled') _cancelledInfo(context, order),
        const SizedBox(height: 16),
        ...((order['items'] as List?) ?? const [])
            .whereType<Map<dynamic, dynamic>>()
            .map((i) {
          return ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('${i['product_name']}'),
            subtitle: Text('x${i['quantity']} · Rs ${i['line_total']}'),
          );
        }),
        if (proofs.isNotEmpty) _paymentProofs(context, proofs),
        const SizedBox(height: 16),
        _cancelSection(context, order),
        if (canUploadProof)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: FilledButton(
              onPressed: _uploadProof,
              child: const Text('Upload payment receipt'),
            ),
          ),
      ],
    );
  }
}
