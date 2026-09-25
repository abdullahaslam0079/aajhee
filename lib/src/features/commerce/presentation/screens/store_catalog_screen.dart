import 'package:aajhee/src/features/commerce/data/commerce_api_service.dart';
import 'package:aajhee/src/features/home/data/models/map_branch_model.dart';
import 'package:aajhee/src/features/settings/presentation/providers/saved_addresses_provider.dart';
import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';
import 'package:aajhee/src/routing/app_routes.dart';
import 'package:aajhee/src/services/dio_service.dart';
import 'package:aajhee/src/services/url_launcher_service.dart';

class StoreCatalogScreen extends ConsumerStatefulWidget {
  const StoreCatalogScreen({super.key, required this.branch});

  final MapBranchModel branch;

  @override
  ConsumerState<StoreCatalogScreen> createState() => _StoreCatalogScreenState();
}

class _StoreCatalogScreenState extends ConsumerState<StoreCatalogScreen> {
  final _api = CommerceApiService(DioService.instance);
  Map<String, dynamic>? _catalog;
  bool _loading = true;
  String? _error;

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
    final branchId = widget.branch.id;
    final result = await _api.getBranchCatalog(
      branchId,
      addressId: addressId,
    );
    if (!mounted) return;
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
      await launcher.launch(value); // whatsapp / phone formatting
    }
  }

  @override
  Widget build(BuildContext context) {
    final business =
        Map<String, dynamic>.from(_catalog?['business'] as Map? ?? {});
    final contacts =
        (_catalog?['contacts'] as List? ?? []).cast<Map<String, dynamic>>();
    final discounted =
        (_catalog?['discounted'] as List? ?? []).cast<Map<String, dynamic>>();
    final categories =
        (_catalog?['categories'] as List? ?? []).cast<Map<String, dynamic>>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.branch.businessName),
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.cart),
            icon: const Icon(Icons.shopping_bag_outlined),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!),
                      FilledButton(onPressed: _load, child: const Text('Retry')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        widget.branch.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(widget.branch.formattedAddress),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          if (business['show_online'] == true)
                            const Chip(label: Text('Online')),
                          if (business['show_instore'] == true)
                            const Chip(label: Text('In-store')),
                        ],
                      ),
                      if (contacts.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Contact',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Wrap(
                          spacing: 8,
                          children: contacts
                              .map(
                                (c) => ActionChip(
                                  label: Text(
                                    c['contact_type']?.toString() ?? 'contact',
                                  ),
                                  onPressed: () => _contact(c),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                      if (discounted.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Text(
                          'Offers',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        ...discounted.map(_productTile),
                      ],
                      for (final cat in categories) ...[
                        const SizedBox(height: 20),
                        Text(
                          cat['category_name']?.toString() ?? 'Category',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        ...((cat['products'] as List? ?? [])
                                .cast<Map<String, dynamic>>())
                            .map(_productTile),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _productTile(Map<String, dynamic> product) {
    final hasDiscount = product['has_discount'] == true;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(product['name']?.toString() ?? ''),
      subtitle: Text(
        hasDiscount
            ? 'Rs ${product['effective_price']} · ${product['effective_discount_percent']}% off'
            : 'Rs ${product['base_price']}',
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push(
                      '${AppRoutes.productDetail('${product['id']}')}?branch_id=${widget.branch.id}',
        extra: product,
      ),
    );
  }
}
