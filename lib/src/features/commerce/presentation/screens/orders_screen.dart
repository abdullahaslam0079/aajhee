import 'package:aajhee/src/features/commerce/data/commerce_api_service.dart';
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
                    color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
                  ),
                ),
                title: Text('${o['business_name']} · Rs ${o['total']}'),
                subtitle: Text('${o['status']} · ${o['fulfillment_type']}'),
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

  @override
  Widget build(BuildContext context) {
    final order = _order;
    return Scaffold(
      appBar: AppBar(title: const Text('Order')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : order == null
              ? const Center(child: Text('Not found'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      'Status: ${order['status']}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text('Total: Rs ${order['total']}'),
                    Text('Fulfillment: ${order['fulfillment_type']}'),
                    Text('Payment: ${order['payment_method']}'),
                    if ((order['bank_transfer_instructions'] ?? '')
                        .toString()
                        .isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Bank details:\n${order['bank_transfer_instructions']}',
                        ),
                      ),
                    const SizedBox(height: 16),
                    ...((order['items'] as List?) ?? []).map((item) {
                      final i = item as Map;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('${i['product_name']}'),
                        subtitle:
                            Text('x${i['quantity']} · Rs ${i['line_total']}'),
                      );
                    }),
                    const SizedBox(height: 16),
                    if (order['can_customer_cancel'] == true)
                      OutlinedButton(
                        onPressed: () async {
                          await _api.cancelOrder(widget.publicId);
                          _load();
                        },
                        child: const Text('Cancel order'),
                      ),
                    if (order['payment_method'] == 'bank_transfer' &&
                        (order['status'] == 'awaiting_payment' ||
                            order['status'] == 'accepted' ||
                            order['status'] == 'payment_submitted'))
                      FilledButton(
                        onPressed: _uploadProof,
                        child: const Text('Upload payment receipt'),
                      ),
                  ],
                ),
    );
  }
}
