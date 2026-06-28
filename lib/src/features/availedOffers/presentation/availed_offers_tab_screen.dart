import 'package:goluto/src/features/mapFeature/presentation/constants/map_constants.dart';
import 'package:goluto/src/features/auth/presentation/providers/session_provider.dart';
import 'package:goluto/src/features/availedOffers/presentation/providers/availed_offers_provider.dart';
import 'package:goluto/src/features/availedOffers/presentation/widgets/availed_offer_card.dart';
import 'package:goluto/src/features/bottomNavigator/presentation/controllers/bottom_nav_bar_controller.dart';
import 'package:goluto/src/features/offerScanner/domain/offer_scanner_session.dart';
import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';

class AvailedOffersTabScreen extends ConsumerStatefulWidget {
  const AvailedOffersTabScreen({super.key});

  @override
  ConsumerState<AvailedOffersTabScreen> createState() =>
      _AvailedOffersTabScreenState();
}

class _AvailedOffersTabScreenState
    extends ConsumerState<AvailedOffersTabScreen> {
  int? _lastSeenTabIndex;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final session = ref.watch(sessionProvider);
    final selectedIndex = ref.watch(bottomNavBarControllerProvider);
    final availedState = ref.watch(availedOffersProvider);

    if (_lastSeenTabIndex != selectedIndex) {
      _lastSeenTabIndex = selectedIndex;
      if (selectedIndex == 2 &&
          session.status == SessionStatus.authenticated) {
        Future.microtask(
          () => ref.read(availedOffersProvider.notifier).load(),
        );
      }
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('My Offers'),
        centerTitle: false,
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.surface,
      ),
      body: SafeArea(
        child: session.status != SessionStatus.authenticated
            ? _UnauthenticatedState(
                onLogin: () => context.push(AppRoutes.login),
              )
            : availedState.isLoading && availedState.offers.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : availedState.errorMessage != null &&
                  availedState.offers.isEmpty
            ? _ErrorState(
                message: availedState.errorMessage!,
                onRetry: () =>
                    ref.read(availedOffersProvider.notifier).load(),
              )
            : availedState.offers.isEmpty
            ? _EmptyState(
                onScan: () => context.push(
                  AppRoutes.offerScanner,
                  extra: const OfferScannerSession(
                    navigateToBranchOnSuccess: true,
                  ),
                ),
                onBrowse: () => ref
                    .read(bottomNavBarControllerProvider.notifier)
                    .setSelectedIndex(0),
              )
            : RefreshIndicator(
                onRefresh: () =>
                    ref.read(availedOffersProvider.notifier).load(),
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.sm.w,
                    AppSpacing.sm.h,
                    AppSpacing.sm.w,
                    MapConstants.bottomNavInset.h + AppSpacing.lg.h,
                  ),
                  itemCount: availedState.offers.length,
                  separatorBuilder: (_, __) =>
                      SizedBox(height: AppSpacing.md.h),
                  itemBuilder: (context, index) {
                    final availedOffer = availedState.offers[index];
                    return AvailedOfferCard(
                      availedOffer: availedOffer,
                      onTap: () => context.push(
                        AppRoutes.businessStore,
                        extra: availedOffer.toMapBranch(),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}

class _UnauthenticatedState extends StatelessWidget {
  const _UnauthenticatedState({required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final textTheme = context.theme.textTheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_offer_outlined,
              size: 56,
              color: colorScheme.primary.withValues(alpha: 0.75),
            ),
            SizedBox(height: AppSpacing.md.h),
            Text(
              'Sign in to see your offers',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: AppSpacing.sm.h),
            Text(
              'Offers you avail at stores will appear here.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: AppSpacing.lg.h),
            FilledButton(
              onPressed: onLogin,
              child: const Text('Sign in'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.onScan,
    required this.onBrowse,
  });

  final VoidCallback onScan;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final textTheme = context.theme.textTheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 56,
              color: colorScheme.primary.withValues(alpha: 0.75),
            ),
            SizedBox(height: AppSpacing.md.h),
            Text(
              'No availed offers yet',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: AppSpacing.sm.h),
            Text(
              'Scan a QR code at a store to avail your first offer.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: AppSpacing.lg.h),
            FilledButton(
              onPressed: onScan,
              child: const Text('Scan offer'),
            ),
            SizedBox(height: AppSpacing.sm.h),
            TextButton(
              onPressed: onBrowse,
              child: const Text('Browse stores'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final textTheme = context.theme.textTheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: colorScheme.error.withValues(alpha: 0.75),
            ),
            SizedBox(height: AppSpacing.md.h),
            Text(
              'Could not load offers',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: AppSpacing.sm.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: AppSpacing.lg.h),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
