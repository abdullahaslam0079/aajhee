import 'package:aajhee/src/features/mapFeature/presentation/constants/map_constants.dart';
import 'package:aajhee/src/features/auth/presentation/providers/session_provider.dart';
import 'package:aajhee/src/features/availedOffers/presentation/providers/availed_offers_provider.dart';
import 'package:aajhee/src/features/availedOffers/presentation/widgets/availed_offer_card.dart';
import 'package:aajhee/src/features/bottomNavigator/presentation/controllers/bottom_nav_bar_controller.dart';
import 'package:aajhee/src/features/offers/offer_feature_flags.dart';
import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';

class AvailedOffersTabScreen extends ConsumerStatefulWidget {
  const AvailedOffersTabScreen({super.key});

  @override
  ConsumerState<AvailedOffersTabScreen> createState() =>
      _AvailedOffersTabScreenState();
}

class _AvailedOffersTabScreenState
    extends ConsumerState<AvailedOffersTabScreen> {
  final _scrollController = ScrollController();
  int? _lastSeenTabIndex;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 240) {
      ref.read(availedOffersProvider.notifier).loadMore();
    }
  }

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
            ? const AppLoading(message: 'Loading your offers...')
            : availedState.errorMessage != null &&
                  availedState.offers.isEmpty
            ? AppErrorWidget(
                title: 'Could not load offers',
                message: availedState.errorMessage,
                onRetry: () =>
                    ref.read(availedOffersProvider.notifier).load(),
              )
            : availedState.offers.isEmpty
            ? AppEmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'No availed offers yet',
                subtitle: kOfferScannerEnabled
                    ? 'Scan a QR code at a store to avail your first offer.'
                    : 'Browse stores on Home to explore current offers.',
                actionLabel: kOfferScannerEnabled
                    ? 'Browse stores'
                    : 'Browse offers',
                onAction: () => ref
                    .read(bottomNavBarControllerProvider.notifier)
                    .setSelectedIndex(0),
              )
            : RefreshIndicator(
                onRefresh: () =>
                    ref.read(availedOffersProvider.notifier).load(),
                child: ListView.separated(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.sm.w,
                    AppSpacing.sm.h,
                    AppSpacing.sm.w,
                    MapConstants.bottomNavInset.h + AppSpacing.lg.h,
                  ),
                  itemCount: availedState.offers.length +
                      (availedState.isLoadingMore ? 1 : 0),
                  separatorBuilder: (_, __) =>
                      SizedBox(height: AppSpacing.md.h),
                  itemBuilder: (context, index) {
                    if (index >= availedState.offers.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: AppLoading(size: 22, strokeWidth: 2.5),
                      );
                    }
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
    return AppEmptyState(
      icon: Icons.local_offer_outlined,
      title: 'Sign in to see your offers',
      subtitle: 'Offers you avail at stores will appear here.',
      actionLabel: 'Sign in',
      onAction: onLogin,
    );
  }
}
