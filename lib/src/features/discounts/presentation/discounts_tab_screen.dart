import 'dart:async';

import 'package:goluto/src/features/businessStore/presentation/widgets/offer_detail_sheet.dart';
import 'package:goluto/src/features/bottomNavigator/presentation/controllers/bottom_nav_bar_controller.dart';
import 'package:goluto/src/features/discounts/data/services/engagement_service.dart';
import 'package:goluto/src/features/discounts/presentation/providers/discounts_provider.dart';
import 'package:goluto/src/features/discounts/presentation/widgets/discount_offer_card.dart';
import 'package:goluto/src/features/home/data/models/offer_model.dart';
import 'package:goluto/src/features/mapFeature/presentation/constants/map_constants.dart';
import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';

class DiscountsTabScreen extends ConsumerStatefulWidget {
  const DiscountsTabScreen({super.key});

  @override
  ConsumerState<DiscountsTabScreen> createState() => _DiscountsTabScreenState();
}

class _DiscountsTabScreenState extends ConsumerState<DiscountsTabScreen> {
  int? _lastSeenTabIndex;

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(bottomNavBarControllerProvider);
    final discountsState = ref.watch(discountsFeedProvider);
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final bottomInset = kHomeFeedBottomInset + MediaQuery.paddingOf(context).bottom;

    if (_lastSeenTabIndex != selectedIndex) {
      _lastSeenTabIndex = selectedIndex;
      if (selectedIndex == 2) {
        Future.microtask(() => ref.read(discountsFeedProvider.notifier).load());
      }
    }

    return Scaffold(
      backgroundColor: kHomeCanvasColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.ms.w,
                AppSpacing.sm.h,
                AppSpacing.ms.w,
                AppSpacing.sm.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Discounts',
                    style: tt.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm.h),
                  _DealsHighlightBanner(colorScheme: cs, textTheme: tt),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => ref.read(discountsFeedProvider.notifier).load(),
                child: discountsState.isLoading && discountsState.offers.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: 160.h),
                          const Center(child: CircularProgressIndicator()),
                        ],
                      )
                    : discountsState.errorMessage != null &&
                          discountsState.offers.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
                        children: [
                          SizedBox(height: 120.h),
                          _ErrorState(
                            message: discountsState.errorMessage!,
                            onRetry: () =>
                                ref.read(discountsFeedProvider.notifier).load(),
                          ),
                        ],
                      )
                    : discountsState.offers.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
                        children: [
                          SizedBox(height: 120.h),
                          _EmptyState(
                            onBrowse: () => ref
                                .read(bottomNavBarControllerProvider.notifier)
                                .setSelectedIndex(0),
                          ),
                        ],
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.ms.w,
                          0,
                          AppSpacing.ms.w,
                          bottomInset,
                        ),
                        itemCount: discountsState.offers.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(height: AppSpacing.ms.h),
                        itemBuilder: (context, index) {
                          final offer = discountsState.offers[index];
                          return DiscountOfferCard(
                            offer: offer,
                            onTap: () => _openOffer(context, offer),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openOffer(BuildContext context, OfferModel offer) async {
    unawaited(EngagementService.instance.recordOfferView(offer.id));

    await showOfferDetailSheet(
      context,
      offer: offer,
      storeName: offer.businessName,
    );
  }
}

class _DealsHighlightBanner extends StatelessWidget {
  const _DealsHighlightBanner({
    required this.colorScheme,
    required this.textTheme,
  });

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final onBanner = colorScheme.onPrimary;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.ms.w,
        vertical: AppSpacing.sm.h,
      ),
      decoration: BoxDecoration(
        borderRadius: AppBorders.lg,
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.88),
            appColors.warning.withValues(alpha: 0.85),
          ],
        ),
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: onBanner.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_fire_department_rounded,
              color: onBanner,
              size: 22,
            ),
          ),
          SizedBox(width: AppSpacing.sm.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Top picks for you',
                  style: textTheme.titleSmall?.copyWith(
                    color: onBanner,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Best deals from stores nearby',
                  style: textTheme.labelSmall?.copyWith(
                    color: onBanner.withValues(alpha: 0.88),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onBrowse});

  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    return Column(
      children: [
        Icon(
          Icons.local_offer_outlined,
          size: 56,
          color: cs.primary.withValues(alpha: 0.75),
        ),
        SizedBox(height: AppSpacing.md.h),
        Text(
          'No discounts yet',
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        SizedBox(height: AppSpacing.sm.h),
        Text(
          'Check back soon for standout offers from nearby stores.',
          textAlign: TextAlign.center,
          style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        ),
        SizedBox(height: AppSpacing.lg.h),
        FilledButton(onPressed: onBrowse, child: const Text('Browse stores')),
      ],
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
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    return Column(
      children: [
        Icon(Icons.error_outline_rounded, size: 56, color: cs.error),
        SizedBox(height: AppSpacing.md.h),
        Text(
          message,
          textAlign: TextAlign.center,
          style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        ),
        SizedBox(height: AppSpacing.lg.h),
        FilledButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    );
  }
}
