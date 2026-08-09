import 'dart:async';

import 'package:goluto/src/features/businessStore/presentation/widgets/offer_detail_sheet.dart';
import 'package:goluto/src/features/discounts/presentation/widgets/discount_offer_card.dart';
import 'package:goluto/src/features/home/data/models/offer_model.dart';
import 'package:goluto/src/features/searchOffers/presentation/providers/search_offers_provider.dart';
import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';

class SearchOffersScreen extends ConsumerStatefulWidget {
  const SearchOffersScreen({super.key});

  @override
  ConsumerState<SearchOffersScreen> createState() => _SearchOffersScreenState();
}

class _SearchOffersScreenState extends ConsumerState<SearchOffersScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _controller
      ..removeListener(_onTextChanged)
      ..dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 240) {
      ref.read(searchOffersProvider.notifier).loadMore();
    }
  }

  void _submitSearch([String? value]) {
    FocusScope.of(context).unfocus();
    unawaited(
      ref
          .read(searchOffersProvider.notifier)
          .search(value ?? _controller.text),
    );
  }

  void _clearSearch() {
    _controller.clear();
    ref.read(searchOffersProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchOffersProvider);
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    return Scaffold(
      backgroundColor: homeCanvasOf(context),
      appBar: AppBar(
        backgroundColor: homeCanvasOf(context),
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Search offers',
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.ms.w,
              AppSpacing.xs.h,
              AppSpacing.ms.w,
              AppSpacing.sm.h,
            ),
            child: AppTextField(
              controller: _controller,
              autofocus: true,
              hint: 'Search brands or items…',
              textInputAction: TextInputAction.search,
              prefixIcon: IconButton(
                tooltip: 'Search',
                onPressed: _hasText ? () => _submitSearch() : null,
                icon: Icon(
                  Icons.search_rounded,
                  color: cs.onSurfaceVariant,
                ),
              ),
              suffixIcon: _hasText
                  ? IconButton(
                      tooltip: 'Clear',
                      onPressed: _clearSearch,
                      icon: Icon(
                        Icons.close_rounded,
                        color: cs.onSurfaceVariant,
                      ),
                    )
                  : null,
              onFieldSubmitted: _submitSearch,
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(searchOffersProvider.notifier).refresh(),
              child: _buildBody(context, state, cs, tt),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    SearchOffersState state,
    ColorScheme cs,
    TextTheme tt,
  ) {
    if (!state.hasQuery) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
        children: [
          SizedBox(height: 120.h),
          Icon(
            Icons.search_rounded,
            size: 56,
            color: cs.primary.withValues(alpha: 0.7),
          ),
          SizedBox(height: AppSpacing.md.h),
          Text(
            'Find offers near you',
            textAlign: TextAlign.center,
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: AppSpacing.sm.h),
          Text(
            'Type a product like “PS5” or a brand, then press Search.',
            textAlign: TextAlign.center,
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      );
    }

    if (state.isLoading && state.offers.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 160.h),
          const Center(child: CircularProgressIndicator()),
        ],
      );
    }

    if (state.errorMessage != null && state.offers.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
        children: [
          SizedBox(height: 120.h),
          Icon(Icons.error_outline_rounded, size: 56, color: cs.error),
          SizedBox(height: AppSpacing.md.h),
          Text(
            state.errorMessage!,
            textAlign: TextAlign.center,
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          SizedBox(height: AppSpacing.lg.h),
          Center(
            child: FilledButton(
              onPressed: () =>
                  ref.read(searchOffersProvider.notifier).refresh(),
              child: const Text('Retry'),
            ),
          ),
        ],
      );
    }

    if (state.offers.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
        children: [
          SizedBox(height: 120.h),
          Icon(
            Icons.local_offer_outlined,
            size: 56,
            color: cs.primary.withValues(alpha: 0.7),
          ),
          SizedBox(height: AppSpacing.md.h),
          Text(
            'No offers found',
            textAlign: TextAlign.center,
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: AppSpacing.sm.h),
          Text(
            'Nothing matched “${state.query}”. Try another brand or item.',
            textAlign: TextAlign.center,
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      );
    }

    final itemCount = state.offers.length + (state.isLoadingMore ? 1 : 0);

    return ListView.separated(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.ms.w,
        0,
        AppSpacing.ms.w,
        AppSpacing.xl.h + MediaQuery.paddingOf(context).bottom,
      ),
      itemCount: itemCount,
      separatorBuilder: (_, __) => SizedBox(height: AppSpacing.ms.h),
      itemBuilder: (context, index) {
        if (index >= state.offers.length) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md.h),
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            ),
          );
        }

        final offer = state.offers[index];
        return DiscountOfferCard(
          offer: offer,
          onTap: () => _openOffer(context, offer),
        );
      },
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
