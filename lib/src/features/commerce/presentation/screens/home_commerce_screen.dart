import 'package:aajhee/src/features/commerce/data/commerce_api_service.dart';
import 'package:aajhee/src/features/home/presentation/widgets/delivery_address_picker_sheet.dart';
import 'package:aajhee/src/features/home/presentation/widgets/home_header.dart';
import 'package:aajhee/src/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:aajhee/src/features/settings/presentation/providers/saved_addresses_provider.dart';
import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';
import 'package:aajhee/src/routing/app_routes.dart';
import 'package:aajhee/src/services/dio_service.dart';

class HomeCommerceScreen extends ConsumerStatefulWidget {
  const HomeCommerceScreen({super.key});

  @override
  ConsumerState<HomeCommerceScreen> createState() => _HomeCommerceScreenState();
}

class _HomeCommerceScreenState extends ConsumerState<HomeCommerceScreen> {
  final _api = CommerceApiService(DioService.instance);
  Map<String, dynamic>? _feeds;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final addressId = ref.read(savedAddressesProvider).selectedAddress?.id;
    final result = await _api.getHomeFeeds(addressId: addressId);
    if (!mounted) return;
    result.fold(
      (f) => setState(() {
        _loading = false;
        _error = f.message;
      }),
      (data) => setState(() {
        _loading = false;
        _feeds = data;
      }),
    );
  }

  List<Map<String, dynamic>> _section(String key) {
    final raw = _feeds?[key];
    if (raw is List) return raw.cast<Map<String, dynamic>>();
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    final addresses = ref.watch(savedAddressesProvider);
    final unread = ref.watch(notificationsProvider).unreadCount;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
                  child: Column(
                    children: [
                      HomeHeader(
                        locationText: addresses.selectedAddress?.city ??
                            'Add address',
                        onLocationTap: () =>
                            showDeliveryAddressPicker(context, ref),
                        onFavoritesTap: () => context.push(AppRoutes.favorites),
                        onNotificationsTap: () =>
                            context.push(AppRoutes.notifications),
                        notificationUnreadCount: unread,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          tooltip: 'Cart',
                          onPressed: () => context.push(AppRoutes.cart),
                          icon: const Icon(Icons.shopping_bag_outlined),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 8.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Aajhee',
                        style: tt.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Discover local picks, offers, and trending products.',
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_loading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null)
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_error!),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: _load,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else ...[
                _ProductSection(
                  title: 'Top picks for you',
                  products: _section('top_picks'),
                ),
                _ProductSection(
                  title: 'Offers',
                  products: _section('offers'),
                ),
                _ProductSection(
                  title: 'Trending',
                  products: _section('trending'),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 100.h)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductSection extends StatelessWidget {
  const _ProductSection({required this.title, required this.products});

  final String title;
  final List<Map<String, dynamic>> products;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
    final tt = Theme.of(context).textTheme;
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(top: 16.h, bottom: 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                title,
                style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              height: 210.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: products.length,
                separatorBuilder: (_, __) => SizedBox(width: 12.w),
                itemBuilder: (context, index) {
                  final p = products[index];
                  return _ProductCard(product: p);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final Map<String, dynamic> product;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasDiscount = product['has_discount'] == true;
    return InkWell(
      onTap: () => context.push(
        AppRoutes.productDetail('${product['id']}'),
        extra: product,
      ),
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 150.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  image: product['image_url'] != null
                      ? DecorationImage(
                          image: NetworkImage(product['image_url'].toString()),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: product['image_url'] == null
                    ? const Center(child: Icon(Icons.image_outlined))
                    : null,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              product['name']?.toString() ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              hasDiscount
                  ? 'Rs ${product['effective_price']} · ${product['effective_discount_percent']}% off'
                  : 'Rs ${product['effective_price'] ?? product['base_price']}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: hasDiscount ? cs.primary : cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
