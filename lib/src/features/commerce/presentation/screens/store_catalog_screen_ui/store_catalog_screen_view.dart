part of 'package:aajhee/src/features/commerce/presentation/screens/store_catalog_screen.dart';

class _StoreCatalogScreenState extends ConsumerState<StoreCatalogScreen>
    with StoreCatalogScreenController {
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
    final discountedRaw =
        (_catalog?['discounted'] as List? ?? []).cast<Map<String, dynamic>>();
    final discounted =
        discountedRaw.where(_isTrulyDiscounted).toList(growable: false);
    final categories =
        (_catalog?['categories'] as List? ?? []).cast<Map<String, dynamic>>();

    final showOnline = business['show_online'] == true;
    final showInStore = business['show_instore'] == true;
    final businessName =
        (business['name']?.toString().trim().isNotEmpty ?? false)
            ? business['name'].toString()
            : (widget.args.businessName ??
                widget.args.branch?.businessName ??
                'Shop');
    final branchName =
        (branchData['name']?.toString().trim().isNotEmpty ?? false)
            ? branchData['name'].toString()
            : (widget.args.branch?.name ?? '');
    final address =
        (branchData['formatted_address']?.toString().trim().isNotEmpty ?? false)
            ? branchData['formatted_address'].toString()
            : ((branchData['formattedAddress']?.toString().trim().isNotEmpty ??
                    false)
                ? branchData['formattedAddress'].toString()
                : (widget.args.branch?.formattedAddress ?? ''));
    final lat =
        _asDouble(branchData['latitude']) ?? widget.args.branch?.latitude;
    final lng =
        _asDouble(branchData['longitude']) ?? widget.args.branch?.longitude;
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

    final feedBranch = _matchingFeedBranch(businessId);
    final isVerified = business['is_verified'] == true ||
        business['verified'] == true ||
        branchData['is_verified'] == true ||
        branchData['verified'] == true ||
        (feedBranch?.isVerified ?? false) ||
        (widget.args.branch?.isVerified ?? false);

    final maps = [branchData, business];
    final sameDayFlag = _flagFromMaps(maps, [
          'supports_same_day',
          'same_day_enabled',
          'same_day_delivery',
        ]) ??
        (feedBranch?.supportsSameDay) ??
        widget.args.branch?.supportsSameDay;
    final nationwideFlag = _flagFromMaps(maps, [
          'supports_nationwide',
          'nationwide_delivery',
        ]) ??
        (feedBranch?.supportsNationwide) ??
        widget.args.branch?.supportsNationwide;
    final fulfillment = branchData['fulfillment_types'] ??
        branchData['fulfillment_modes'] ??
        business['fulfillment_types'] ??
        business['fulfillment_modes'];

    final supportsSameDay = (sameDayFlag ?? false) ||
        _listHasSameDay(fulfillment) ||
        (sameDayFlag == null &&
            nationwideFlag == null &&
            ((feedBranch?.treatsAsSameDay ?? false) ||
                (widget.args.branch?.treatsAsSameDay ?? false)));
    final supportsNationwide =
        (nationwideFlag ?? false) || _listHasNationwide(fulfillment);

    final deliveryFee = _feeFromMaps(maps) ??
        feedBranch?.deliveryFee ??
        widget.args.branch?.deliveryFee;
    final deliveryFeeLabel = formatRsOrNull(deliveryFee);
    final openingHours = _pickHours(
      business: business,
      branchData: branchData,
      feedBranch: feedBranch ?? widget.args.branch,
    );

    Map<String, dynamic>? whatsappContact;
    final otherContacts = <Map<String, dynamic>>[];
    for (final contact in contacts) {
      final type =
          (contact['contact_type']?.toString() ?? '').trim().toLowerCase();
      if (type == 'whatsapp' && whatsappContact == null) {
        whatsappContact = contact;
      } else {
        otherContacts.add(contact);
      }
    }

    final productSections =
        <({String title, List<Map<String, dynamic>> items})>[
      if (discounted.isNotEmpty) (title: 'On sale', items: discounted),
      for (final cat in categories)
        (
          title: cat['category_name']?.toString() ?? 'Category',
          items:
              ((cat['products'] as List? ?? []).cast<Map<String, dynamic>>()),
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
        title: const Text('Shop'),
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
                            ratingCount: int.tryParse(
                                    '${business['rating_count'] ?? 0}') ??
                                0,
                            isVerified: isVerified,
                            supportsSameDay: supportsSameDay,
                            supportsNationwide: supportsNationwide,
                            deliveryFeeLabel: deliveryFeeLabel,
                            openingHours: openingHours,
                            showOnline: showOnline,
                            showInStore: showInStore,
                            address: showInStore ? address : '',
                            canNavigate:
                                showInStore && lat != null && lng != null,
                            whatsappContact: whatsappContact,
                            contacts: otherContacts,
                            onNavigate: lat != null && lng != null
                                ? () => _openGoogleMaps(
                                      latitude: lat,
                                      longitude: lng,
                                    )
                                : null,
                            onContact: _contact,
                            whatsAppColor:
                                StoreCatalogScreenController._whatsAppGreen,
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
                                  'This shop has not published listings yet.',
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
}
