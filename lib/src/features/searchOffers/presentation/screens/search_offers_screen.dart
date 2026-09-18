import 'dart:async';

import 'package:aajhee/src/features/businessStore/presentation/widgets/offer_detail_sheet.dart';
import 'package:aajhee/src/features/offers/presentation/widgets/offer_list_card.dart';
import 'package:aajhee/src/features/home/data/models/offer_model.dart';
import 'package:aajhee/src/features/searchOffers/presentation/providers/search_offers_provider.dart';
import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';

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
              child: _buildBody(context, state),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    SearchOffersState state,
  ) {
    if (!state.hasQuery) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 80),
          AppEmptyState(
            icon: Icons.search_rounded,
            title: 'Find offers near you',
            subtitle:
                'Type a product like “PS5” or a brand, then press Search.',
          ),
        ],
      );
    }

    if (state.isLoading && state.offers.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 160),
          AppLoading(message: 'Searching offers...'),
        ],
      );
    }

    if (state.errorMessage != null && state.offers.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 80.h),
          AppErrorWidget(
            title: 'Could not search offers',
            message: state.errorMessage,
            onRetry: () => ref.read(searchOffersProvider.notifier).refresh(),
          ),
        ],
      );
    }

    if (state.offers.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 80.h),
          AppEmptyState(
            icon: Icons.local_offer_outlined,
            title: 'No offers found',
            subtitle:
                'Nothing matched “${state.query}”. Try another brand or item.',
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
            child: const AppLoading(size: 22, strokeWidth: 2.5),
          );
        }

        final offer = state.offers[index];
        return OfferListCard(
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
