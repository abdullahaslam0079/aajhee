import 'dart:async';

import 'package:goluto/src/features/discounts/data/services/engagement_service.dart';
import 'package:goluto/src/features/home/data/models/offer_model.dart';
import 'package:goluto/src/features/offers/presentation/widgets/offer_image_carousel.dart';
import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';

Future<void> showOfferDetailSheet(
  BuildContext context, {
  required OfferModel offer,
  required String storeName,
  String? storeLogoUrl,
}) {
  // Count a view whenever the detail sheet opens (any entry point).
  unawaited(EngagementService.instance.recordOfferView(offer.id));

  return showAppSheet(
    child: _OfferDetailSheet(
      offer: offer,
      storeName: storeName,
      storeLogoUrl: storeLogoUrl ?? offer.businessLogoUrl,
    ),
  );
}

class _OfferDetailSheet extends StatelessWidget {
  const _OfferDetailSheet({
    required this.offer,
    required this.storeName,
    this.storeLogoUrl,
  });

  final OfferModel offer;
  final String storeName;
  final String? storeLogoUrl;

  Future<void> _openExternalLink(BuildContext context) async {
    final url = offer.resolvedExternalUrl;
    if (url == null) return;

    final result = await UrlLauncherService.instance.launch(url);
    if (!context.mounted) return;

    result.fold(
      (failure) => showToast(
        context,
        message: failure.message,
        status: 'error',
      ),
      (_) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final muted = cs.onSurface.withValues(alpha: 0.62);
    final galleryUrls = offer.displayImageUrls;
    final dealTypeLabel =
        offer.offerType == OfferType.item ? 'Item deal' : 'Flat off';
    final shortDescription = offer.description.trim();
    final detailedDescription = offer.detailedDescription.trim();
    final detailsBody = detailedDescription.isNotEmpty
        ? detailedDescription
        : (shortDescription.isNotEmpty ? shortDescription : offer.subtitle);
    // Only show the blurb when it adds something beyond the details section.
    // Otherwise the same text appears twice (bold blurb + "Product details").
    final showShortBlurb =
        shortDescription.isNotEmpty && shortDescription != detailsBody;
    final externalUrl = offer.resolvedExternalUrl;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.88;
    final hasPrices =
        offer.originalPrice != null && offer.discountedPrice != null;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        color: cs.surfaceContainerLowest,
        elevation: 8,
        shadowColor: Colors.black26,
        borderRadius: AppBorders.bottomSheet,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: maxHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ColoredBox(
                color: cs.surfaceContainerLowest,
                child: Column(
                  children: [
                    SizedBox(height: AppSpacing.sm.h),
                    Center(
                      child: Container(
                        width: 44.w,
                        height: 5.h,
                        decoration: BoxDecoration(
                          color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                          borderRadius: AppBorders.full,
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs.h),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.ms.w,
                    AppSpacing.sm.h,
                    AppSpacing.ms.w,
                    AppSpacing.xl.h + MediaQuery.paddingOf(context).bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        offer.title,
                        style: tt.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs.h),
                      Row(
                        children: [
                          StoreLogoBadge(
                            name: storeName,
                            imageUrl: storeLogoUrl,
                            size: 28,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              storeName,
                              style: tt.bodyMedium?.copyWith(
                                color: muted,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (galleryUrls.isNotEmpty) ...[
                        SizedBox(height: AppSpacing.md.h),
                        OfferImageCarousel(
                          imageUrls: galleryUrls,
                          height: 200.h,
                          debugLabel: 'offer detail ${offer.title}',
                          onImageTap: (index) => showFullScreenImageGallery(
                            context,
                            imageUrls: galleryUrls,
                            initialIndex: index,
                          ),
                        ),
                      ],
                      if (hasPrices) ...[
                        SizedBox(height: AppSpacing.md.h),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: AppSpacing.sm.w,
                          runSpacing: AppSpacing.xs.h,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  offer.discountedPrice!.asEuro,
                                  style: tt.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: context.appColors.deal,
                                    letterSpacing: -0.4,
                                    height: 1,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  offer.originalPrice!.asEuro,
                                  style: tt.titleMedium?.copyWith(
                                    color: muted,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.lineThrough,
                                    decorationColor: muted,
                                  ),
                                ),
                              ],
                            ),
                            if (offer.discountPercent > 0)
                              _DetailChip(
                                label:
                                    '${offer.discountPercent.toStringAsFixed(0)}% off',
                                icon: Icons.local_offer_outlined,
                                accent: true,
                              ),
                          ],
                        ),
                      ] else if (offer.detailText.isNotEmpty) ...[
                        SizedBox(height: AppSpacing.sm.h),
                        Text(
                          offer.detailText,
                          style: tt.bodyMedium?.copyWith(
                            color: muted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ] else if (offer.discountPercent > 0) ...[
                        SizedBox(height: AppSpacing.sm.h),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: _DetailChip(
                            label:
                                '${offer.discountPercent.toStringAsFixed(0)}% off',
                            icon: Icons.local_offer_outlined,
                            accent: true,
                          ),
                        ),
                      ],
                      if (showShortBlurb) ...[
                        SizedBox(height: AppSpacing.md.h),
                        Text(
                          shortDescription,
                          style: tt.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                          ),
                        ),
                      ],
                      if (detailsBody.isNotEmpty) ...[
                        SizedBox(height: AppSpacing.md.h),
                        Text(
                          'Product details',
                          style: tt.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        SizedBox(height: AppSpacing.xs.h),
                        Text(
                          detailsBody,
                          style: tt.bodyLarge?.copyWith(height: 1.5),
                        ),
                      ],
                      SizedBox(height: AppSpacing.md.h),
                      Wrap(
                        spacing: AppSpacing.xs.w,
                        runSpacing: AppSpacing.xxs.h,
                        children: [
                          _DetailChip(
                            label: dealTypeLabel,
                            icon: Icons.storefront_outlined,
                          ),
                          if (offer.isOnline)
                            const _DetailChip(
                              label: 'Online',
                              icon: Icons.language_rounded,
                            ),
                          if (offer.isViewOnlyOffer)
                            const _DetailChip(
                              label: 'View only',
                              icon: Icons.visibility_outlined,
                            ),
                        ],
                      ),
                      if (externalUrl != null) ...[
                        SizedBox(height: AppSpacing.lg.h),
                        FilledButton.icon(
                          onPressed: () => _openExternalLink(context),
                          icon: const Icon(Icons.open_in_new_rounded, size: 20),
                          label: Text(offer.externalLinkButtonLabel(storeName)),
                        ),
                      ],
                      SizedBox(height: AppSpacing.md.h),
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({
    required this.label,
    required this.icon,
    this.accent = false,
  });

  final String label;
  final IconData icon;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final appColors = context.appColors;
    final backgroundColor = accent
        ? appColors.deal.withValues(alpha: 0.12)
        : cs.surfaceContainerHigh;
    final foregroundColor = accent
        ? (appColors.onDealContainer ?? appColors.deal)
        : cs.onSurfaceVariant;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xs.w,
        vertical: AppSpacing.xxs.h,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppBorders.full,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: accent ? appColors.deal : cs.onSurfaceVariant,
          ),
          SizedBox(width: 4.w),
          Text(
            label,
            style: tt.labelSmall?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
