// import 'package:goluto/src/features/offers/offer_feature_flags.dart';
// import 'package:goluto/src/features/offerScanner/domain/offer_scanner_session.dart';
import 'package:goluto/src/features/mapFeature/presentation/constants/map_constants.dart';
import 'package:goluto/src/features/settings/presentation/settings.dart';
import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';
import 'package:goluto/src/features/bottomNavigator/presentation/controllers/bottom_nav_bar_controller.dart';
import 'package:goluto/src/features/discounts/presentation/discounts_tab_screen.dart';
import 'package:goluto/src/features/mapFeature/presentation/map_screen.dart';

class BottomNavigationBarScreen extends ConsumerWidget {
  const BottomNavigationBarScreen({super.key});

  // static const double _fabSize = 62;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(bottomNavBarControllerProvider);
    // final colorScheme = context.theme.colorScheme;

    return Scaffold(
      backgroundColor: kHomeCanvasColor,
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
              ? const DiscountsTabScreen()
              : const SettingsScreen(),
        ),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // floatingActionButton: SizedBox(
      //   height: _fabSize,
      //   width: _fabSize,
      //   child: FloatingActionButton(
      //     onPressed: () {
      //       if (!kOfferScannerEnabled) {
      //         showToast(
      //           context,
      //           message: 'Offer scanning is coming soon.',
      //           status: 'info',
      //         );
      //         return;
      //       }
      //       context.push(
      //         AppRoutes.offerScanner,
      //         extra: const OfferScannerSession(
      //           navigateToBranchOnSuccess: true,
      //         ),
      //       );
      //     },
      //     backgroundColor: colorScheme.primary,
      //     foregroundColor: Colors.white,
      //     elevation: 8,
      //     highlightElevation: 10,
      //     focusElevation: 10,
      //     hoverElevation: 10,
      //     shape: const CircleBorder(),
      //     child: const Icon(Icons.qr_code_scanner_rounded, size: 28),
      //   ),
      // ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 16,
        shadowColor: Colors.black.withValues(alpha: 0.14),
        height: kBottomNavBarHeight,
        padding: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: const AutomaticNotchedShape(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(kBottomNavBarBorderRadius),
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
            // const SizedBox(width: 72), // Spacer for scanner FAB notch
            Expanded(
              child: _BottomItem(
                icon: selectedIndex == 2
                    ? Icons.local_offer_rounded
                    : Icons.local_offer_outlined,
                label: 'Discounts',
                selected: selectedIndex == 2,
                onTap: () => ref
                    .read(bottomNavBarControllerProvider.notifier)
                    .setSelectedIndex(2),
              ),
            ),
            Expanded(
              child: _BottomItem(
                icon: selectedIndex == 3
                    ? Icons.tune_rounded
                    : Icons.tune_outlined,
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
    final inactive = cs.onSurface.withValues(alpha: 0.45);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 23,
            color: selected ? cs.primary : inactive,
          ),
          SizedBox(height: 3.h),
          Text(
            label,
            style: context.theme.textTheme.labelMedium?.copyWith(
              color: selected ? cs.onSurface : inactive,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
