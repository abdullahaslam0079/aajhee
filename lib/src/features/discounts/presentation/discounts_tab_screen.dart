import 'dart:async';

import 'package:goluto/src/features/auth/presentation/providers/session_provider.dart';
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
    final bottomInset = kHomeFeedBottomInset + MediaQuery.paddingOf(context).bottom;

    if (_lastSeenTabIndex != selectedIndex) {
      _lastSeenTabIndex = selectedIndex;
      if (selectedIndex == 2) {
        Future.microtask(() => ref.read(discountsFeedProvider.notifier).load());
      }
    }

    return Scaffold(
      backgroundColor: kHomeCanvasColor,
      appBar: AppBar(
        title: const Text('Discounts'),
        centerTitle: false,
        scrolledUnderElevation: 0,
        backgroundColor: kHomeCanvasColor,
      ),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => ref.read(discountsFeedProvider.notifier).load(),
          child: discountsState.isLoading && discountsState.offers.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: 180.h),
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
                    AppSpacing.sm.w,
                    AppSpacing.sm.h,
                    AppSpacing.sm.w,
                    bottomInset,
                  ),
                  itemCount: discountsState.offers.length,
                  separatorBuilder: (_, __) => SizedBox(height: AppSpacing.md.h),
                  itemBuilder: (context, index) {
                    final offer = discountsState.offers[index];
                    return DiscountOfferCard(
                      offer: offer,
                      onTap: () => _openOffer(context, ref, offer),
                      onToggleOfferLike: () => _toggleOfferLike(ref, offer),
                      onToggleBusinessLike: () => _toggleBusinessLike(ref, offer),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Future<void> _openOffer(
    BuildContext context,
    WidgetRef ref,
    OfferModel offer,
  ) async {
    unawaited(EngagementService.instance.recordOfferView(offer.id));
    ref.read(discountsFeedProvider.notifier).updateOffer(
          offer.copyWithEngagement(viewCount: offer.viewCount + 1),
        );

    await showOfferDetailSheet(
      context,
      offer: offer,
      storeName: offer.businessName,
    );
  }

  Future<void> _toggleOfferLike(WidgetRef ref, OfferModel offer) async {
    if (!_ensureSignedIn(ref)) return;

    final result = await EngagementService.instance.toggleOfferLike(offer.id);
    if (!mounted) return;

    result.fold(
      (failure) => showToast(
        context,
        message: failure.message,
        status: 'error',
      ),
      (engagement) {
        ref.read(discountsFeedProvider.notifier).updateOffer(
              offer.copyWithEngagement(
                likeCount: engagement.likeCount,
                isLiked: engagement.isLiked,
              ),
            );
      },
    );
  }

  Future<void> _toggleBusinessLike(WidgetRef ref, OfferModel offer) async {
    if (!_ensureSignedIn(ref)) return;

    final result =
        await EngagementService.instance.toggleBusinessLike(offer.businessId);
    if (!mounted) return;

    result.fold(
      (failure) => showToast(
        context,
        message: failure.message,
        status: 'error',
      ),
      (engagement) {
        ref.read(discountsFeedProvider.notifier).updateOffer(
              offer.copyWithEngagement(
                businessLikeCount: engagement.likeCount,
                isBusinessLiked: engagement.isLiked,
              ),
            );
      },
    );
  }

  bool _ensureSignedIn(WidgetRef ref) {
    final session = ref.read(sessionProvider);
    if (session.status == SessionStatus.authenticated) return true;

    showToast(
      context,
      message: 'Sign in to like offers and stores.',
      status: 'info',
    );
    context.push(AppRoutes.login);
    return false;
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
          'Top offers from nearby stores will show up here.',
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
