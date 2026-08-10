import 'package:goluto/src/features/businessStore/presentation/widgets/offer_detail_sheet.dart';
import 'package:goluto/src/features/home/data/models/offer_model.dart';
import 'package:goluto/src/features/offers/presentation/providers/top_picks_provider.dart';
import 'package:goluto/src/features/offers/presentation/widgets/offer_list_card.dart';
import 'package:goluto/src/features/offers/presentation/widgets/offers_home_chrome.dart';
import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';

/// Full list of curated top picks, opened from Home via View all.
class TopPicksScreen extends ConsumerStatefulWidget {
  const TopPicksScreen({super.key});

  @override
  ConsumerState<TopPicksScreen> createState() => _TopPicksScreenState();
}

class _TopPicksScreenState extends ConsumerState<TopPicksScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(() {
      final state = ref.read(topPicksFeedProvider);
      if (state.offers.isEmpty && !state.isLoading) {
        ref.read(topPicksFeedProvider.notifier).load();
      }
    });
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
      ref.read(topPicksFeedProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(topPicksFeedProvider);
    final tt = context.theme.textTheme;
    final bottomInset = MediaQuery.paddingOf(context).bottom + AppSpacing.lg.h;

    return Scaffold(
      backgroundColor: homeCanvasOf(context),
      appBar: AppBar(
        title: Text(
          'Top picks',
          style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(topPicksFeedProvider.notifier).load(),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.ms.w,
                  AppSpacing.sm.h,
                  AppSpacing.ms.w,
                  AppSpacing.md.h,
                ),
                child: const TopPicksHighlightBanner(),
              ),
            ),
            if (state.isLoading && state.offers.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.errorMessage != null && state.offers.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
                  child: _ErrorState(
                    message: state.errorMessage!,
                    onRetry: () =>
                        ref.read(topPicksFeedProvider.notifier).load(),
                  ),
                ),
              )
            else if (state.offers.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
                  child: const _EmptyState(),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.ms.w,
                  0,
                  AppSpacing.ms.w,
                  bottomInset,
                ),
                sliver: SliverList.separated(
                  itemCount:
                      state.offers.length + (state.isLoadingMore ? 1 : 0),
                  separatorBuilder: (_, __) =>
                      SizedBox(height: AppSpacing.ms.h),
                  itemBuilder: (context, index) {
                    if (index >= state.offers.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final offer = state.offers[index];
                    return OfferListCard(
                      offer: offer,
                      onTap: () => _openOffer(context, offer),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _openOffer(BuildContext context, OfferModel offer) async {
    await showOfferDetailSheet(
      context,
      offer: offer,
      storeName: offer.businessName,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.local_fire_department_outlined,
          size: 56,
          color: cs.primary.withValues(alpha: 0.75),
        ),
        SizedBox(height: AppSpacing.md.h),
        Text(
          'No top picks yet',
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        SizedBox(height: AppSpacing.sm.h),
        Text(
          'Check back soon for standout deals nearby and online.',
          textAlign: TextAlign.center,
          style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        ),
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
      mainAxisAlignment: MainAxisAlignment.center,
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
