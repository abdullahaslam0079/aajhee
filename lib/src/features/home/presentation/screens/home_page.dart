import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';

import 'package:goluto/src/features/businessStore/presentation/widgets/business_store_card.dart';
import 'package:goluto/src/features/home/presentation/widgets/delivery_address_picker_sheet.dart';
import 'package:goluto/src/features/location/presentation/providers/location_provider.dart';
import 'package:goluto/src/features/home/presentation/widgets/category_widget.dart';
import 'package:goluto/src/features/home/presentation/widgets/home_header.dart';
import 'package:goluto/src/features/mapFeature/presentation/constants/map_constants.dart';
import 'package:goluto/src/features/settings/presentation/providers/saved_addresses_provider.dart';
import 'package:goluto/src/features/shared/data/dummy_berlin_items.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  static const List<String> _categoryLabels = [
    'All',
    'Food',
    'Fasion',
    'Beauty & Cosmetics',
    'Entertainment',
    'Salon & Spa',
    'Heatlth',
    'Travel',
    'Fitness',
    'Home & Living',
    'LifeStyle & Hobbies',
    'Electronics',
    'Mother & Babycare',
    'Education',
    'Gift & Specialty',
    'Vehicles & Auto',
    'Professional Services',
    'Grocery',
    'Nicotine',
    'Financial & Legal Services',
    'Logistics',
  ];

  static const List<IconData> _categoryIcons = [
    Icons.apps_rounded,
    Icons.restaurant_rounded,
    Icons.checkroom_outlined,
    Icons.spa_outlined,
    Icons.movie_outlined,
    Icons.content_cut_outlined,
    Icons.health_and_safety_outlined,
    Icons.flight_outlined,
    Icons.fitness_center_outlined,
    Icons.home_outlined,
    Icons.palette_outlined,
    Icons.devices_outlined,
    Icons.child_care_outlined,
    Icons.school_outlined,
    Icons.card_giftcard_outlined,
    Icons.directions_car_outlined,
    Icons.work_outline_rounded,
    Icons.shopping_basket_outlined,
    Icons.smoke_free_outlined,
    Icons.account_balance_outlined,
    Icons.local_shipping_outlined,
  ];

  late int _selectedCategoryIndex;

  @override
  void initState() {
    super.initState();
    _selectedCategoryIndex = 0;
    Future.microtask(() {
      ref.read(locationProvider.notifier).ensureLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.theme.textTheme;

    final locationState = ref.watch(locationProvider);
    final savedAddressesState = ref.watch(savedAddressesProvider);
    final selectedAddress = savedAddressesState.selectedAddress;
    const items = dummyBerlinItems;
    final locationText = selectedAddress?.shortLabel ??
        locationState.address ??
        'Add delivery address';

    final bottomInset = kHomeFeedBottomInset +
        MediaQuery.paddingOf(context).bottom +
        AppSpacing.lg.h;

    return Scaffold(
      backgroundColor: kHomeCanvasColor,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: HomeHeader(
                locationText: locationText,
                onLocationTap: () => showDeliveryAddressPicker(context, ref),
                onFavoritesTap: () => context.push(AppRoutes.favorites),
                onNotificationsTap: () => context.push(AppRoutes.notifications),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _HomeCategoriesHeaderDelegate(
                selectedCategoryIndex: _selectedCategoryIndex,
                categoryLabels: _categoryLabels,
                categoryIcons: _categoryIcons,
                onCategoryTap: _onCategoryTap,
                textTheme: textTheme,
                backgroundColor: kHomeCanvasColor,
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.sm.w,
                AppSpacing.lg.h,
                AppSpacing.sm.w,
                0,
              ),
              sliver: SliverList.separated(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return BusinessStoreCard(
                    item: item,
                    onTap: () {
                      context.push(AppRoutes.businessStore);
                    },
                  );
                },
                separatorBuilder: (_, __) => SizedBox(height: AppSpacing.md.h),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: bottomInset)),
          ],
        ),
      ),
    );
  }

  void _onCategoryTap(int index) {
    if (_selectedCategoryIndex == index) return;
    setState(() => _selectedCategoryIndex = index);
  }
}

class _HomeCategoriesHeaderDelegate extends SliverPersistentHeaderDelegate {
  _HomeCategoriesHeaderDelegate({
    required this.selectedCategoryIndex,
    required this.categoryLabels,
    required this.categoryIcons,
    required this.onCategoryTap,
    required this.textTheme,
    required this.backgroundColor,
  });

  final int selectedCategoryIndex;
  final List<String> categoryLabels;
  final List<IconData> categoryIcons;
  final ValueChanged<int> onCategoryTap;
  final TextTheme textTheme;
  final Color backgroundColor;

  static const double _chipRowHeight = 44;

  double get _extent =>
      AppSpacing.sm.h + 24.h + AppSpacing.sm.h + _chipRowHeight.h;

  @override
  double get minExtent => _extent;

  @override
  double get maxExtent => _extent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: backgroundColor,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.sm.w,
          AppSpacing.sm.h,
          AppSpacing.sm.w,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Categories',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.sm.h),
            SizedBox(
              height: _chipRowHeight.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: categoryLabels.length,
                separatorBuilder: (_, __) => const SizedBox.shrink(),
                itemBuilder: (context, index) {
                  return CategoryWidget(
                    label: categoryLabels[index],
                    icon: categoryIcons[index],
                    onTap: () => onCategoryTap(index),
                    selectedCategoryIndex: selectedCategoryIndex,
                    index: index,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _HomeCategoriesHeaderDelegate oldDelegate) {
    return selectedCategoryIndex != oldDelegate.selectedCategoryIndex ||
        textTheme != oldDelegate.textTheme ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}
