part of 'package:aajhee/src/features/commerce/presentation/screens/store_catalog_screen.dart';

class _StoreCatalogScreenState extends ConsumerState<StoreCatalogScreen>
    with StoreCatalogScreenController {
  @override
  Widget build(BuildContext context) {
    ref.listen(savedAddressesProvider, (previous, next) {
      if (!next.selectedLocationChangedFrom(previous)) return;
      _load();
    });

    final canvas = homeCanvasOf(context);
    final cartCount = ref.watch(
      cartProvider.select((state) => state.totalQuantity),
    );

    final header = _header;
    final home = _home;
    final business = header?.business;
    final branch = header?.branch;

    final showOnline = business?.showOnline ?? false;
    final showInStore = business?.showInStore ?? false;
    final businessName = (business?.name.trim().isNotEmpty ?? false)
        ? business!.name
        : (widget.args.businessName ??
            widget.args.branch?.businessName ??
            'Shop');
    final branchName = (branch?.name.isNotEmpty ?? false)
        ? branch!.name
        : (widget.args.branch?.name ?? '');
    final address = (branch?.formattedAddress.isNotEmpty ?? false)
        ? branch!.formattedAddress
        : (widget.args.branch?.formattedAddress ?? '');
    final lat = branch?.latitude ?? widget.args.branch?.latitude;
    final lng = branch?.longitude ?? widget.args.branch?.longitude;
    final businessId = business?.id ??
        widget.args.resolvedBusinessId ??
        widget.args.branch?.businessId;
    final logoUrl = business?.logoUrl ??
        widget.args.logoUrl ??
        widget.args.branch?.businessLogoUrl ??
        (businessId != null
            ? ref.watch(
                homeFeedProvider.select(
                  (s) => s.logoUrlForBusiness(businessId),
                ),
              )
            : null);
    final catalogBranchId =
        branch?.id ?? widget.args.resolvedBranchId ?? widget.args.branch?.id;

    final feedBranch = _matchingFeedBranch(businessId);
    final favoriteBranchId = catalogBranchId ?? feedBranch?.id;
    final isFavorite = favoriteBranchId != null
        ? ref.watch(
            favoriteStoresProvider.select(
              (state) => state.isFavorite(favoriteBranchId),
            ),
          )
        : false;

    final isVerified = (business?.isVerified ?? false) ||
        (feedBranch?.isVerified ?? false) ||
        (widget.args.branch?.isVerified ?? false);

    final supportsSameDay = header != null
        ? _supportsSameDay(header: header, feedBranch: feedBranch)
        : (feedBranch?.treatsAsSameDay ??
            widget.args.branch?.treatsAsSameDay ??
            false);
    final supportsNationwide = header != null
        ? _supportsNationwide(header: header, feedBranch: feedBranch)
        : (feedBranch?.supportsNationwide ??
            widget.args.branch?.supportsNationwide ??
            false);

    final openingHours = _pickHours(
      header: header,
      feedBranch: feedBranch ?? widget.args.branch,
    );
    final categoryName = _pickCategoryName(feedBranch ?? widget.args.branch);
    final distanceKm = _distanceKm(feedBranch ?? widget.args.branch);

    final ratingAvg = branch?.ratingAvg ??
        (feedBranch?.ratingAvg != null
            ? feedBranch!.ratingAvg!.toStringAsFixed(1)
            : widget.args.branch?.ratingAvg?.toStringAsFixed(1)) ??
        business?.ratingAvg;
    final ratingCount = (branch != null && branch.ratingCount > 0)
        ? branch.ratingCount
        : (feedBranch?.ratingCount ??
            widget.args.branch?.ratingCount ??
            business?.ratingCount ??
            0);

    Map<String, dynamic>? whatsappContact;
    final otherContacts = <Map<String, dynamic>>[];
    for (final contact in header?.contacts ?? const <StoreContact>[]) {
      final json = contact.toJson();
      if (contact.contactType == 'whatsapp' && whatsappContact == null) {
        whatsappContact = json;
      } else {
        otherContacts.add(json);
      }
    }

    final browseTabs = <StoreBrowseTab>[
      if ((home?.deals.count ?? 0) > 0)
        const StoreBrowseTab(id: StoreBrowseTab.dealsId, title: 'On sale'),
      for (final cat in home?.categories ?? const <StoreCategoryShelf>[])
        if (cat.productCount > 0)
          StoreBrowseTab(
            id: 'category_${cat.categoryId}',
            title: cat.categoryName,
            categoryId: cat.categoryId,
          ),
    ];

    final shelfRows = <({String title, List<CommerceProduct> products})>[
      if ((home?.deals.preview.isNotEmpty ?? false))
        (title: 'On sale', products: home!.deals.preview),
      for (final cat in home?.categories ?? const <StoreCategoryShelf>[])
        if (cat.preview.isNotEmpty)
          (title: cat.categoryName, products: cat.preview),
    ];

    final totalProducts = (home?.deals.count ?? 0) +
        (home?.categories.fold<int>(
              0,
              (sum, cat) => sum + cat.productCount,
            ) ??
            0);

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
                        if (shelfRows.isEmpty)
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
                          for (var i = 0; i < shelfRows.length; i++) ...[
                            SliverToBoxAdapter(
                              child: _StoreSectionHeader(
                                title: shelfRows[i].title,
                                onSeeAll: () {
                                  final tabIndex = browseTabs.indexWhere(
                                    (tab) => tab.title == shelfRows[i].title,
                                  );
                                  _openCategoryBrowse(
                                    storeName: businessName,
                                    tabs: browseTabs,
                                    initialIndex:
                                        tabIndex >= 0 ? tabIndex : i,
                                    branchId: catalogBranchId,
                                    businessId: businessId,
                                  );
                                },
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: _StoreProductCarousel(
                                products: shelfRows[i].products,
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
                            padding:
                                EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 28.h),
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
