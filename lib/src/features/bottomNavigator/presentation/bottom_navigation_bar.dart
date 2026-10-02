import 'package:aajhee/src/features/mapFeature/presentation/constants/map_constants.dart';
import 'package:aajhee/src/features/settings/presentation/settings.dart';
import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';
import 'package:aajhee/src/features/bottomNavigator/presentation/controllers/bottom_nav_bar_controller.dart';
import 'package:aajhee/src/features/commerce/presentation/providers/active_orders_badge_provider.dart';
import 'package:aajhee/src/features/commerce/presentation/screens/home_commerce_screen.dart';
import 'package:aajhee/src/features/commerce/presentation/screens/orders_screen.dart';
import 'package:aajhee/src/features/home/presentation/screens/stores_tab_screen.dart';

class BottomNavigationBarScreen extends ConsumerWidget {
  const BottomNavigationBarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(bottomNavBarControllerProvider);
    final activeOrdersCount =
        ref.watch(activeOrdersBadgeProvider).value ?? 0;

    return Scaffold(
      backgroundColor: homeCanvasOf(context),
      extendBody: true,
      body: _KeptTabs(index: selectedIndex.clamp(0, 3)),
      bottomNavigationBar: BottomAppBar(
        color: context.theme.colorScheme.surfaceContainerLowest,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        height: kBottomNavBarHeight,
        padding: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: AutomaticNotchedShape(
          RoundedRectangleBorder(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(kBottomNavBarBorderRadius),
            ),
            side: BorderSide(
              color: context.theme.colorScheme.outlineVariant,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: _BottomItem(
                icon: selectedIndex == 0
                    ? Icons.home_rounded
                    : Icons.home_outlined,
                label: 'Home',
                selected: selectedIndex == 0,
                onTap: () => ref
                    .read(bottomNavBarControllerProvider.notifier)
                    .setSelectedIndex(0),
              ),
            ),
            Expanded(
              child: _BottomItem(
                icon: selectedIndex == 1
                    ? Icons.storefront_rounded
                    : Icons.storefront_outlined,
                label: 'Shops',
                selected: selectedIndex == 1,
                onTap: () => ref
                    .read(bottomNavBarControllerProvider.notifier)
                    .setSelectedIndex(1),
              ),
            ),
            Expanded(
              child: _BottomItem(
                icon: selectedIndex == 2
                    ? Icons.receipt_long_rounded
                    : Icons.receipt_long_outlined,
                label: 'Orders',
                selected: selectedIndex == 2,
                badgeCount: activeOrdersCount,
                onTap: () => ref
                    .read(bottomNavBarControllerProvider.notifier)
                    .setSelectedIndex(2),
              ),
            ),
            Expanded(
              child: _BottomItem(
                icon: selectedIndex == 3
                    ? Icons.person_rounded
                    : Icons.person_outline_rounded,
                label: 'Profile',
                selected: selectedIndex == 3,
                onTap: () => ref
                    .read(bottomNavBarControllerProvider.notifier)
                    .setSelectedIndex(3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Builds a tab the first time it is opened, then keeps that instance.
/// Switching tabs no longer disposes Home, Shops, Orders, or Profile.
class _KeptTabs extends StatefulWidget {
  const _KeptTabs({required this.index});

  final int index;

  @override
  State<_KeptTabs> createState() => _KeptTabsState();
}

class _KeptTabsState extends State<_KeptTabs> {
  static const _pages = <Widget>[
    HomeCommerceScreen(),
    StoresTabScreen(),
    OrdersScreen(),
    SettingsScreen(),
  ];

  final List<Widget?> _tabs = List<Widget?>.filled(4, null);

  @override
  Widget build(BuildContext context) {
    final index = widget.index.clamp(0, _pages.length - 1);
    _tabs[index] ??= _pages[index];
    return IndexedStack(
      index: index,
      sizing: StackFit.expand,
      children: [
        for (final tab in _tabs) tab ?? const SizedBox.shrink(),
      ],
    );
  }
}

class _BottomItem extends StatelessWidget {
  const _BottomItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final color = selected ? colorScheme.primary : colorScheme.onSurfaceVariant;
    final showBadge = badgeCount > 0;
    final badgeLabel = badgeCount > 99 ? '99+' : '$badgeCount';

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, color: color, size: 24),
              if (showBadge)
                Positioned(
                  top: -4,
                  right: -10,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.error,
                      borderRadius: AppBorders.full,
                      border: Border.all(
                        color: colorScheme.surfaceContainerLowest,
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      badgeLabel,
                      style: TextStyle(
                        color: colorScheme.onError,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: context.theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
