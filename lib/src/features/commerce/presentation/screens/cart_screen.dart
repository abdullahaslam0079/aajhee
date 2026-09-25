import 'package:aajhee/src/features/commerce/data/commerce_api_service.dart';
import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';
import 'package:aajhee/src/routing/app_routes.dart';
import 'package:aajhee/src/services/dio_service.dart';
import 'package:aajhee/src/features/settings/presentation/providers/saved_addresses_provider.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final _api = CommerceApiService(DioService.instance);
  Map<String, dynamic>? _cart;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await _api.getCart();
    if (!mounted) return;
    result.fold(
      (f) => setState(() {
        _loading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(f.message)),
        );
      }),
      (cart) => setState(() {
        _cart = cart;
        _loading = false;
      }),
    );
  }

  List<Map<String, dynamic>> get _items {
    final raw = _cart?['items'];
    if (raw is List) return raw.cast<Map<String, dynamic>>();
    return const [];
  }

  Future<void> _checkout() async {
    final items = _items;
    if (items.isEmpty) return;

    // Group by branch; fall back to product.branch_ids.first
    final groups = <int, List<int>>{};
    for (final item in items) {
      int? branchId = item['branch_id'] as int?;
      if (branchId == null) {
        final product =
            Map<String, dynamic>.from(item['product'] as Map? ?? {});
        final branchIds = product['branch_ids'];
        if (branchIds is List && branchIds.isNotEmpty) {
          branchId = branchIds.first as int;
        }
      }
      if (branchId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Open a store to add items with a pickup location, or set product branches.',
            ),
          ),
        );
        return;
      }
      groups.putIfAbsent(branchId, () => []).add(item['id'] as int);
    }

    final addressId = ref.read(savedAddressesProvider).selectedAddress?.id;
    final checkoutGroups = <Map<String, dynamic>>[];

    for (final entry in groups.entries) {
      final preview = await _api.checkoutPreview(
        branchId: entry.key,
        itemIds: entry.value,
        addressId: addressId,
      );
      final previewData = preview.fold((f) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(f.message)),
        );
        return null;
      }, (d) => d);
      if (previewData == null) return;

      final options = (previewData['options'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .where((o) => o['available'] == true)
          .toList();
      if (options.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No delivery options available.')),
        );
        return;
      }

      final payments = Map<String, dynamic>.from(
        previewData['payment_methods'] as Map? ?? {},
      );
      final fulfillment = await showModalBottomSheet<String>(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(title: Text('Choose fulfillment')),
              ...options.map(
                (o) => ListTile(
                  title: Text(o['label']?.toString() ?? o['fulfillment_type']),
                  subtitle: Text('Fee: Rs ${o['fee']}'),
                  onTap: () =>
                      Navigator.pop(context, o['fulfillment_type']?.toString()),
                ),
              ),
            ],
          ),
        ),
      );
      if (fulfillment == null) return;

      String? paymentMethod;
      final methods = <String>[];
      if (fulfillment == 'pickup' && payments['cash_on_pickup'] == true) {
        methods.add('cash_on_pickup');
      }
      if (fulfillment != 'pickup' && payments['cash_on_delivery'] == true) {
        methods.add('cash_on_delivery');
      }
      if (payments['bank_transfer'] == true) {
        methods.add('bank_transfer');
      }
      if (methods.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No payment methods available.')),
        );
        return;
      }
      paymentMethod = await showModalBottomSheet<String>(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(title: Text('Payment method')),
              ...methods.map(
                (m) => ListTile(
                  title: Text(m.replaceAll('_', ' ')),
                  subtitle: m == 'bank_transfer'
                      ? Text(payments['bank_transfer_instructions']?.toString() ?? '')
                      : null,
                  onTap: () => Navigator.pop(context, m),
                ),
              ),
            ],
          ),
        ),
      );
      if (paymentMethod == null) return;

      checkoutGroups.add({
        'branch_id': entry.key,
        'item_ids': entry.value,
        'fulfillment_type': fulfillment,
        'payment_method': paymentMethod,
        'delivery_address_text':
            ref.read(savedAddressesProvider).selectedAddress?.formattedAddress ??
                '',
      });
    }

    final placed = await _api.placeOrders(
      groups: checkoutGroups,
      addressId: addressId,
    );
    if (!mounted) return;
    placed.fold(
      (f) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(f.message)),
      ),
      (orders) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Placed ${orders.length} order(s)')),
        );
        context.go(AppRoutes.orders);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _items.isEmpty ? null : _checkout,
            child: Text('Checkout · Rs ${_cart?['subtotal'] ?? '0'}'),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(child: Text('Your cart is empty'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    final product =
                        Map<String, dynamic>.from(item['product'] as Map? ?? {});
                    return ListTile(
                      title: Text(product['name']?.toString() ?? 'Item'),
                      subtitle: Text(
                        'Qty ${item['quantity']} · Rs ${item['line_total']}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () async {
                              await _api.updateCartItem(
                                item['id'] as int,
                                (item['quantity'] as int) - 1,
                              );
                              _load();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () async {
                              await _api.updateCartItem(
                                item['id'] as int,
                                (item['quantity'] as int) + 1,
                              );
                              _load();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
