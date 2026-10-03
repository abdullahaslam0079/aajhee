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
    final favoriteBranchId = catalogBranchId ?? feedBranch?.id;
    final isFavorite = favoriteBranchId != null
        ? ref.watch(
            favoriteStoresProvider.select(
              (state) => state.isFavorite(favoriteBranchId),
            ),
          )
        : false;

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

    final openingHours = _pickHours(
      business: business,
      branchData: branchData,
      feedBranch: feedBranch ?? widget.args.branch,
    );
    final categoryName = _pickCategoryName(
      business: business,
      branchData: branchData,
      feedBranch: feedBranch ?? widget.args.branch,
    );
    final distanceKm = _distanceKm(feedBranch ?? widget.args.branch);
    final coverImageUrl = _coverImageUrl(
      business: business,
      branchData: branchData,
      feedBranch: feedBranch ?? widget.args.branch,
      discounted: discounted,
    );

    // Prefer this location's rating; fall back to feed/args, then business rollup.
    final branchRatingAvg = branchData['rating_avg']?.toString() ??
        (feedBranch?.ratingAvg != null
            ? feedBranch!.ratingAvg!.toStringAsFixed(1)
            : widget.args.branch?.ratingAvg?.toStringAsFixed(1));
    final ratingAvg = branchRatingAvg ?? business['rating_avg']?.toString();
    final branchRatingCount = int.tryParse('${branchData['rating_count'] ?? ''}') ??
        feedBranch?.ratingCount ??
        widget.args.branch?.ratingCount;
    final ratingCount = branchRatingCount ??
        int.tryParse('${business['rating_count'] ?? ''}') ??
        0;

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

    final categorySections = categories
        .map(
          (cat) => (
            title: cat['category_name']?.toString() ?? 'Category',
            items:
                ((cat['products'] as List? ?? []).cast<Map<String, dynamic>>()),
          ),
        )
        .where((section) => section.items.isNotEmpty)
        .toList(growable: false);

    final productSections =
        <({String title, List<Map<String, dynamic>> items})>[
      if (discounted.isNotEmpty) (title: 'On sale', items: discounted),
      ...categorySections,
    ];

    final filterLabels = <String>[
      'All',
      ...categorySections.map((s) => s.title),
    ];
    final filteredSections = _categoryFilterIndex <= 0
        ? productSections
        : productSections
            .where(
              (section) =>
                  section.title == filterLabels[_categoryFilterIndex],
            )
            .toList(growable: false);

    final totalProducts = productSections.fold<int>(
      0,
      (sum, section) => sum + section.items.length,
    );

    final favoriteBranch = feedBranch ?? widget.args.branch;

    return Scaffold(
      backgroundColor: canvas,
      appBar: AppBar(
        backgroundColor: canvas,
        title: Text(
          businessName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
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
                            ratingAvg: ratingAvg,
                            ratingCount: ratingCount,
                            isVerified: isVerified,
                            categoryName: categoryName,
                            distanceKm: distanceKm,
                            address: showInStore ? address : '',
                            isFavorite: isFavorite,
                            canFavorite: favoriteBranchId != null,
                            onFavoriteTap: () => _toggleFavorite(
                              favoriteBranchId,
                              favoriteBranch,
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                          child: _StoreHighlights(
                            supportsSameDay: supportsSameDay,
                            supportsNationwide: supportsNationwide,
                            hasWhatsApp: whatsappContact != null,
                            showOnline: showOnline,
                            showInStore: showInStore,
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
                          child: _StoreSegmentTabs(
                            selectedIndex: _tabIndex,
                            onSelected: _selectTab,
                            productCount: totalProducts,
                          ),
                        ),
                      ),
                      if (_tabIndex == 0) ...[
                        if (coverImageUrl != null)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
                              child: _StoreCoverBanner(
                                imageUrl: coverImageUrl,
                                businessName: businessName,
                                categoryName: categoryName,
                                supportsSameDay: supportsSameDay,
                              ),
                            ),
                          ),
                        if (discounted.isNotEmpty &&
                            (_categoryFilterIndex <= 0 ||
                                filterLabels[_categoryFilterIndex] ==
                                    'On sale')) ...[
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                16.w,
                                20.h,
                                16.w,
                                8.h,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.local_offer_outlined,
                                    size: 16,
                                    color: cs.primary,
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    'On sale',
                                    style: tt.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 7.w,
                                      vertical: 2.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: cs.primary.withValues(alpha: 0.1),
                                      borderRadius: AppBorders.full,
                                    ),
                                    child: Text(
                                      '${discounted.length}',
                                      style: tt.labelSmall?.copyWith(
                                        color: cs.primary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: _StoreProductCarousel(
                              products: discounted,
                              onProductTap: (product) =>
                                  _openProduct(product, catalogBranchId),
                              onAddTap: (product) => _addProductToCart(
                                product,
                                branchId: catalogBranchId,
                              ),
                            ),
                          ),
                        ],
                        if (categorySections.isNotEmpty) ...[
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                16.w,
                                18.h,
                                16.w,
                                8.h,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.grid_view_rounded,
                                    size: 16,
                                    color: cs.primary,
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    'Store categories',
                                    style: tt.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: _StoreCategoryCards(
                              sections: categorySections,
                              selectedIndex: _categoryFilterIndex > 0
                                  ? _categoryFilterIndex - 1
                                  : null,
                              onSelected: (index) =>
                                  _selectCategoryFilter(index + 1),
                            ),
                          ),
                          if (filterLabels.length > 1)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.only(top: 14.h),
                                child: _StoreFilterChips(
                                  labels: filterLabels,
                                  selectedIndex: _categoryFilterIndex,
                                  onSelected: _selectCategoryFilter,
                                ),
                              ),
                            ),
                        ],
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
                          for (final section in filteredSections)
                            if (section.title != 'On sale') ...[
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    16.w,
                                    18.h,
                                    16.w,
                                    8.h,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        categoryIconForName(section.title),
                                        size: 16,
                                        color: cs.primary,
                                      ),
                                      SizedBox(width: 6.w),
                                      Expanded(
                                        child: Text(
                                          section.title == 'On sale'
                                              ? 'On sale'
                                              : section.title,
                                          style: tt.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${section.items.length}',
                                        style: tt.labelMedium?.copyWith(
                                          color: cs.onSurfaceVariant,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SliverToBoxAdapter(
                                child: _StoreProductCarousel(
                                  products: section.items,
                                  onProductTap: (product) =>
                                      _openProduct(product, catalogBranchId),
                                  onAddTap: (product) => _addProductToCart(
                                    product,
                                    branchId: catalogBranchId,
                                  ),
                                ),
                              ),
                            ],
                          SliverToBoxAdapter(child: SizedBox(height: 28.h)),
                        ],
                      ] else
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 28.h),
                            child: _StoreAboutPanel(
                              branchName: showInStore ? branchName : '',
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
                    ],
                  ),
                ),
    );
  }
}
