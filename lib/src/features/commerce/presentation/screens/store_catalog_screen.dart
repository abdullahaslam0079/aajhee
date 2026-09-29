import 'package:aajhee/src/features/commerce/data/commerce_api_service.dart';
import 'package:aajhee/src/features/commerce/presentation/providers/cart_provider.dart';
import 'package:aajhee/src/features/home/data/models/map_branch_model.dart';
import 'package:aajhee/src/features/home/presentation/providers/home_feed_provider.dart';
import 'package:aajhee/src/features/settings/presentation/providers/saved_addresses_provider.dart';
import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';

/// Opens a store catalog from a map branch or business/branch ids.
class StoreCatalogArgs {
  const StoreCatalogArgs({
    this.branch,
    this.businessId,
    this.branchId,
    this.businessName,
    this.logoUrl,
  });

  factory StoreCatalogArgs.fromBranch(MapBranchModel branch) {
    return StoreCatalogArgs(
      branch: branch,
      businessId: branch.businessId,
      branchId: branch.id,
      businessName: branch.businessName,
      logoUrl: branch.businessLogoUrl,
    );
  }

  final MapBranchModel? branch;
  final int? businessId;
  final int? branchId;
  final String? businessName;
  final String? logoUrl;

  int? get resolvedBusinessId =>
      businessId ??
      (branch != null && branch!.businessId > 0 ? branch!.businessId : null);

  int? get resolvedBranchId => branchId ?? branch?.id;
}

class StoreCatalogScreen extends ConsumerStatefulWidget {
  const StoreCatalogScreen({super.key, required this.args});

  final StoreCatalogArgs args;

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
        _error = 'Store not found.';
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

  @override
  Widget build(BuildContext context) {
    ref.listen(savedAddressesProvider, (previous, next) {
      if (!next.selectedLocationChangedFrom(previous)) return;
      _load();
    });

    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final canvas = homeCanvasOf(context);
    final cartCount = ref.watch(
      cartProvider.select((state) => state.totalQuantity),
    );
    final business =
        Map<String, dynamic>.from(_catalog?['business'] as Map? ?? {});
    final branchData =
        Map<String, dynamic>.from(_catalog?['branch'] as Map? ?? {});
    final contacts =
        (_catalog?['contacts'] as List? ?? []).cast<Map<String, dynamic>>();
    final discounted =
        (_catalog?['discounted'] as List? ?? []).cast<Map<String, dynamic>>();
    final categories =
        (_catalog?['categories'] as List? ?? []).cast<Map<String, dynamic>>();

    final showOnline = business['show_online'] == true;
    final showInStore = business['show_instore'] == true;
    final businessName =
        (business['name']?.toString().trim().isNotEmpty ?? false)
            ? business['name'].toString()
            : (widget.args.businessName ??
                widget.args.branch?.businessName ??
                'Store');
    final branchName =
        (branchData['name']?.toString().trim().isNotEmpty ?? false)
            ? branchData['name'].toString()
            : (widget.args.branch?.name ?? '');
    final address = (branchData['formatted_address']
                    ?.toString()
                    .trim()
                    .isNotEmpty ??
                false)
        ? branchData['formatted_address'].toString()
        : ((branchData['formattedAddress']?.toString().trim().isNotEmpty ??
                false)
            ? branchData['formattedAddress'].toString()
            : (widget.args.branch?.formattedAddress ?? ''));
    final lat = _asDouble(branchData['latitude']) ??
        widget.args.branch?.latitude;
    final lng = _asDouble(branchData['longitude']) ??
        widget.args.branch?.longitude;
    final businessId = _asInt(business['id']) ??
        widget.args.resolvedBusinessId ??
        widget.args.branch?.businessId;
    final logoUrl = widget.args.logoUrl ??
        widget.args.branch?.businessLogoUrl ??
        (businessId != null
            ? ref.watch(
                homeFeedProvider.select(
                  (s) => s.logoUrlForBusiness(businessId),
                ),
              )
            : null);
    final catalogBranchId = _asInt(branchData['id']) ??
        widget.args.resolvedBranchId ??
        widget.args.branch?.id;

    final productSections = <({String title, List<Map<String, dynamic>> items})>[
      if (discounted.isNotEmpty) (title: 'On sale', items: discounted),
      for (final cat in categories)
        (
          title: cat['category_name']?.toString() ?? 'Category',
          items: ((cat['products'] as List? ?? [])
              .cast<Map<String, dynamic>>()),
        ),
    ];
    final totalProducts = productSections.fold<int>(
      0,
      (sum, section) => sum + section.items.length,
    );

    return Scaffold(
      backgroundColor: canvas,
      appBar: AppBar(
        backgroundColor: canvas,
        title: const Text('Store'),
        actions: [
          IconButton(
            tooltip: 'Cart',
            onPressed: () => context.push(AppRoutes.cart),
            icon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount'),
              child: const Icon(Icons.shopping_bag_outlined),
            ),
          ),
        ],
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
              : RefreshIndicator(
                  onRefresh: _load,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 0),
                          child: _StoreHero(
                            businessName: businessName,
                            branchName: showInStore ? branchName : '',
                            logoUrl: logoUrl,
                            ratingAvg: business['rating_avg']?.toString(),
                            ratingCount:
                                int.tryParse('${business['rating_count'] ?? 0}') ??
                                    0,
                            showOnline: showOnline,
                            showInStore: showInStore,
                            address: showInStore ? address : '',
                            canNavigate:
                                showInStore && lat != null && lng != null,
                            contacts: contacts,
                            onNavigate: lat != null && lng != null
                                ? () => _openGoogleMaps(
                                      latitude: lat,
                                      longitude: lng,
                                    )
                                : null,
                            onContact: _contact,
                          ),
                        ),
                      ),
                      if (productSections.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: const AppEmptyState(
                              icon: Icons.inventory_2_outlined,
                              title: 'No products yet',
                              subtitle:
                                  'This store has not published listings yet.',
                            ),
                          ),
                        )
                      else ...[
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              16.w,
                              22.h,
                              16.w,
                              4.h,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Products',
                                  style: tt.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: cs.onSurface,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 2.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: cs.primary.withValues(alpha: 0.1),
                                    borderRadius: AppBorders.sm,
                                  ),
                                  child: Text(
                                    '$totalProducts',
                                    style: tt.labelMedium?.copyWith(
                                      color: cs.primary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        for (final section in productSections) ...[
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                16.w,
                                14.h,
                                16.w,
                                8.h,
                              ),
                              child: Text(
                                section.title,
                                style: tt.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: cs.onSurface,
                                ),
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
                            sliver: SliverList.separated(
                              itemCount: section.items.length,
                              separatorBuilder: (_, __) =>
                                  SizedBox(height: 10.h),
                              itemBuilder: (context, index) {
                                return _CatalogProductCard(
                                  product: section.items[index],
                                  branchId: catalogBranchId,
                                );
                              },
                            ),
                          ),
                        ],
                        SliverToBoxAdapter(child: SizedBox(height: 28.h)),
                      ],
                    ],
                  ),
                ),
    );
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _asDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

class _StoreHero extends StatelessWidget {
  const _StoreHero({
    required this.businessName,
    required this.branchName,
    required this.logoUrl,
    required this.showOnline,
    required this.showInStore,
    required this.address,
    required this.canNavigate,
    required this.contacts,
    required this.onContact,
    this.ratingAvg,
    this.ratingCount = 0,
    this.onNavigate,
  });

  final String businessName;
  final String branchName;
  final String? logoUrl;
  final String? ratingAvg;
  final int ratingCount;
  final bool showOnline;
  final bool showInStore;
  final String address;
  final bool canNavigate;
  final List<Map<String, dynamic>> contacts;
  final ValueChanged<Map<String, dynamic>> onContact;
  final VoidCallback? onNavigate;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: AppBorders.card,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 8.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppBorders.card.topLeft.x),
              ),
              gradient: LinearGradient(
                colors: [
                  cs.primary,
                  cs.primary.withValues(alpha: 0.65),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    StoreLogoBadge(
                      name: businessName,
                      imageUrl: logoUrl,
                      size: 72,
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            businessName,
                            style: tt.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: cs.onSurface,
                              letterSpacing: -0.4,
                              height: 1.15,
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
                          if (ratingCount > 0) ...[
                            SizedBox(height: 6.h),
                            Text(
                              '★ ${ratingAvg ?? '0.00'} ($ratingCount)',
                              style: tt.labelLarge?.copyWith(
                                color: const Color(0xFFE6A817),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                          SizedBox(height: 10.h),
                          Wrap(
                            spacing: 8.w,
                            runSpacing: 6.h,
                            children: [
                              if (showOnline)
                                const _ChannelChip(
                                  label: 'Ecommerce',
                                  icon: Icons.language_rounded,
                                ),
                              if (showInStore)
                                const _ChannelChip(
                                  label: 'In-store',
                                  icon: Icons.storefront_outlined,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (showInStore && address.isNotEmpty) ...[
                  SizedBox(height: 16.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHigh.withValues(alpha: 0.55),
                      borderRadius: AppBorders.md,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 20,
                          color: cs.primary,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            address,
                            style: tt.bodyMedium?.copyWith(
                              color: cs.onSurface,
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (canNavigate && onNavigate != null) ...[
                  SizedBox(height: 12.h),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: onNavigate,
                      icon: const Icon(Icons.directions_rounded),
                      label: const Text('Navigate to store'),
                    ),
                  ),
                ],
                if (contacts.isNotEmpty) ...[
                  SizedBox(height: 16.h),
                  Text(
                    'Contact',
                    style: tt.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: contacts
                        .map(
                          (contact) => _ContactButton(
                            contact: contact,
                            onPressed: () => onContact(contact),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  const _ContactButton({
    required this.contact,
    required this.onPressed,
  });

  final Map<String, dynamic> contact;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final type = (contact['contact_type']?.toString() ?? 'contact')
        .trim()
        .toLowerCase();
    final value = contact['value']?.toString().trim() ?? '';
    final (icon, label) = switch (type) {
      'phone' => (Icons.phone_rounded, 'Call'),
      'email' => (Icons.mail_outline_rounded, 'Email'),
      'whatsapp' => (Icons.chat_rounded, 'WhatsApp'),
      _ => (Icons.contact_page_outlined, type.isEmpty ? 'Contact' : type),
    };

    return Material(
      color: cs.primary.withValues(alpha: 0.08),
      borderRadius: AppBorders.md,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppBorders.md,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            borderRadius: AppBorders.md,
            border: Border.all(color: cs.primary.withValues(alpha: 0.22)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: cs.primary),
              SizedBox(width: 8.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: tt.labelLarge?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (value.isNotEmpty)
                    Text(
                      value,
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChannelChip extends StatelessWidget {
  const _ChannelChip({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: AppBorders.sm,
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: cs.onSurfaceVariant),
          SizedBox(width: 4.w),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _CatalogProductCard extends StatelessWidget {
  const _CatalogProductCard({
    required this.product,
    this.branchId,
  });

  final Map<String, dynamic> product;
  final int? branchId;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final hasDiscount = product['has_discount'] == true;
    final imageUrl = product['image_url']?.toString();
    final path = branchId != null
        ? '${AppRoutes.productDetail('${product['id']}')}?branch_id=$branchId'
        : AppRoutes.productDetail('${product['id']}');

    return Material(
      color: cs.surfaceContainerLowest,
      borderRadius: AppBorders.card,
      child: InkWell(
        onTap: () => context.push(path, extra: product),
        borderRadius: AppBorders.card,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: AppBorders.card,
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Padding(
            padding: EdgeInsets.all(10.r),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: AppBorders.md,
                  child: SizedBox(
                    width: 76.w,
                    height: 76.w,
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
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['name']?.toString() ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        hasDiscount
                            ? 'Rs ${product['effective_price']} · ${product['effective_discount_percent']}% off'
                            : 'Rs ${product['effective_price'] ?? product['base_price']}',
                        style: tt.bodyMedium?.copyWith(
                          color: hasDiscount
                              ? context.appColors.deal
                              : cs.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'View details',
                        style: tt.labelMedium?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: cs.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
