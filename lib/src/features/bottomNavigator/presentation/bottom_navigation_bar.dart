import 'package:aajhee/src/features/mapFeature/presentation/constants/map_constants.dart';
import 'package:aajhee/src/features/settings/presentation/settings.dart';
import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';
import 'package:aajhee/src/features/bottomNavigator/presentation/controllers/bottom_nav_bar_controller.dart';
import 'package:aajhee/src/features/commerce/presentation/screens/home_commerce_screen.dart';
import 'package:aajhee/src/features/home/presentation/screens/stores_tab_screen.dart';
import 'package:aajhee/src/features/mapFeature/presentation/map_screen.dart';

class BottomNavigationBarScreen extends ConsumerWidget {
  const BottomNavigationBarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(bottomNavBarControllerProvider);

    return Scaffold(
      backgroundColor: homeCanvasOf(context),
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: KeyedSubtree(
          key: ValueKey(selectedIndex),
          child: selectedIndex == 0
              ? const HomeCommerceScreen()
              : selectedIndex == 1
              ? const MapScreen()
              : selectedIndex == 2
              ? const StoresTabScreen()
              : const SettingsScreen(),
        ),
      ),
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
                    ? Icons.explore_rounded
                    : Icons.explore_outlined,
                label: 'Discover',
                selected: selectedIndex == 1,
                onTap: () => ref
                    .read(bottomNavBarControllerProvider.notifier)
                    .setSelectedIndex(1),
              ),
            ),
            Expanded(
              child: _BottomItem(
                icon: selectedIndex == 2
                    ? Icons.storefront_rounded
                    : Icons.storefront_outlined,
                label: 'Stores',
                selected: selectedIndex == 2,
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

class _BottomItem extends StatelessWidget {
  const _BottomItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final color = selected ? colorScheme.primary : colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
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
