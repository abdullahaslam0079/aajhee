import 'package:goluto/src/features/mapFeature/presentation/constants/map_constants.dart';
import 'package:goluto/src/features/settings/presentation/settings.dart';
import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';
import 'package:goluto/src/features/bottomNavigator/presentation/controllers/bottom_nav_bar_controller.dart';
import 'package:goluto/src/features/businessStore/presentation/business_store_screen.dart';
import 'package:goluto/src/features/mapFeature/presentation/map_screen.dart';

class BottomNavigationBarScreen extends ConsumerWidget {
  const BottomNavigationBarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(bottomNavBarControllerProvider);
    final colorScheme = context.theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: KeyedSubtree(
          key: ValueKey(selectedIndex),
          child: selectedIndex == 0
              ? const HomePage()
              : selectedIndex == 1
              ? const MapScreen()
              : selectedIndex == 2
              ? const BusinessStoreScreen()
              : const SettingsScreen(),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        height: 64,
        width: 64,
        child: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.offerScanner),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 2,
        shape: const CircleBorder(),
          child: const Icon(Icons.qr_code_scanner_rounded, size: 30),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          border: Border(
            top: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.7),
              width: 1.1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.18),
              blurRadius: 20,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: BottomAppBar(
          color: Colors.transparent,
          elevation: 0,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          child: SizedBox(
            height: kBottomNavBarHeight,
            child: Row(
            children: [
              Expanded(
                child: _BottomItem(
                  icon: selectedIndex == 0 ? Icons.home_rounded : Icons.home_outlined,
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
              const SizedBox(width: 56),
              Expanded(
                child: _BottomItem(
                  icon: selectedIndex == 2
                      ? Icons.local_offer_rounded
                      : Icons.local_offer_outlined,
                  label: 'Deals',
                  selected: selectedIndex == 2,
                  onTap: () => ref
                      .read(bottomNavBarControllerProvider.notifier)
                      .setSelectedIndex(2),
                ),
              ),
              Expanded(
                child: _BottomItem(
                  icon: selectedIndex == 3 ? Icons.tune_rounded : Icons.tune_outlined,
                  label: 'Settings',
                  selected: selectedIndex == 3,
                  onTap: () => ref
                      .read(bottomNavBarControllerProvider.notifier)
                      .setSelectedIndex(3),
                ),
              ),
            ],
            ),
          ),
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
    final cs = context.theme.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 22,
            color: selected ? cs.primary : cs.onSurface.withValues(alpha: 0.62),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: context.theme.textTheme.labelMedium?.copyWith(
              color: selected ? cs.onSurface : cs.onSurface.withValues(alpha: 0.62),
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
