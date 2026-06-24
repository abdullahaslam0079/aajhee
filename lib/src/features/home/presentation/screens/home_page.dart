import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';

import 'package:goluto/src/features/businessStore/presentation/widgets/business_store_card.dart';
import 'package:goluto/src/features/home/presentation/widgets/delivery_address_picker_sheet.dart';
import 'package:goluto/src/features/location/presentation/providers/location_provider.dart';
import 'package:goluto/src/features/home/presentation/widgets/category_widget.dart';
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
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final locationState = ref.watch(locationProvider);
    final savedAddressesState = ref.watch(savedAddressesProvider);
    final selectedAddress = savedAddressesState.selectedAddress;
    final items = dummyBerlinItems;
    final locationText = selectedAddress?.shortLabel ??
        locationState.address ??
        'Add delivery address';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildAppBar(
        colorScheme: colorScheme,
        textTheme: textTheme,
        locationText: locationText,
        onLocationTap: () => showDeliveryAddressPicker(context, ref),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppSpacing.sm.h),
              Text(
                'Categories',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppSpacing.sm.h),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    _categoryLabels.length,
                    (index) => CategoryWidget(
                      label: _categoryLabels[index],
                      onTap: () => _onCategoryTap(index),
                      selectedCategoryIndex: _selectedCategoryIndex,
                      index: index,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md.h),
                child: Divider(
                  color: colorScheme.primary.withValues(alpha: 0.35),
                  thickness: 0.5,
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.only(bottom: AppSpacing.lg.h),
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
                  separatorBuilder: (_, __) =>
                      SizedBox(height: AppSpacing.md.h),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required String locationText,
    required VoidCallback onLocationTap,
  }) {
    return AppBar(
      backgroundColor: colorScheme.surface,
      centerTitle: false,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: AppSpacing.sm,
      title: InkWell(
        onTap: onLocationTap,
        borderRadius: AppBorders.md,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: AppSpacing.xs.h,
            horizontal: AppSpacing.xs.w,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_on_outlined,
                color: colorScheme.primary,
                size: 22,
              ),
              SizedBox(width: AppSpacing.xs.w),
              Flexible(
                child: Text(
                  locationText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.xxs.w),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: colorScheme.onSurfaceVariant,
                size: 22,
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => context.push(AppRoutes.favorites),
          icon: Icon(
            Icons.favorite_border_rounded,
            color: colorScheme.onSurface,
          ),
        ),
        IconButton(
          onPressed: () => context.push(AppRoutes.notifications),
          icon: Icon(
            Icons.notifications_outlined,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(width: AppSpacing.sm),
      ],
    );
  }

  void _onCategoryTap(int index) {
    if (_selectedCategoryIndex == index) return;
    setState(() => _selectedCategoryIndex = index);
  }
}
