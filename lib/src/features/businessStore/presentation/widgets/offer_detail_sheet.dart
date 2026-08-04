import 'package:goluto/src/features/home/data/models/offer_model.dart';
import 'package:goluto/src/imports/core_imports.dart';
import 'package:goluto/src/imports/packages_imports.dart';

Future<void> showOfferDetailSheet(
  BuildContext context, {
  required OfferModel offer,
  required String storeName,
}) {
  return showAppSheet(
    child: _OfferDetailSheet(offer: offer, storeName: storeName),
  );
}

class _OfferDetailSheet extends StatelessWidget {
  const _OfferDetailSheet({
    required this.offer,
    required this.storeName,
  });

  final OfferModel offer;
  final String storeName;

  static const Color _discountAccent = Color(0xFFFF9500);

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
    final imageUrl =
        offer.imageUrl != null && offer.imageUrl!.isNotEmpty ? offer.imageUrl : null;
    final dealTypeLabel =
        offer.offerType == OfferType.item ? 'Item deal' : 'Flat off';
    final shortDescription = offer.description.trim();
    final detailedDescription = offer.detailedDescription.trim();
    final showShortBlurb = shortDescription.isNotEmpty &&
        (detailedDescription.isEmpty ||
            shortDescription != detailedDescription);
    final detailsBody = detailedDescription.isNotEmpty
        ? detailedDescription
        : (shortDescription.isNotEmpty ? shortDescription : offer.subtitle);
    final externalUrl = offer.resolvedExternalUrl;

    return Material(
      color: cs.surfaceContainerLowest,
      borderRadius: AppBorders.bottomSheet,
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
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: cs.outlineVariant.withValues(alpha: 0.55),
                  borderRadius: AppBorders.full,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.md.h),
            Text(
              offer.title,
              style: tt.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: AppSpacing.xxs.h),
            Text(
              storeName,
              style: tt.bodyMedium?.copyWith(
                color: muted,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (imageUrl != null) ...[
              SizedBox(height: AppSpacing.md.h),
              ClipRRect(
                borderRadius: AppBorders.lg,
                child: NetworkImageWithFallback(
                  primaryUrl: imageUrl,
                  debugLabel: 'offer detail ${offer.title}',
                  height: 180.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorWidget: ColoredBox(
                    color: cs.surfaceContainerHighest,
                    child: SizedBox(
                      height: 180.h,
                      child: Icon(Icons.fastfood_outlined, color: muted),
                    ),
                  ),
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
                style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              SizedBox(height: AppSpacing.xs.h),
              Text(
                detailsBody,
                style: tt.bodyLarge?.copyWith(height: 1.5),
              ),
            ],
            if (offer.detailText.isNotEmpty) ...[
              SizedBox(height: AppSpacing.sm.h),
              Text(
                offer.detailText,
                style: tt.bodyMedium?.copyWith(
                  color: muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            SizedBox(height: AppSpacing.md.h),
            Wrap(
              spacing: AppSpacing.xs.w,
              runSpacing: AppSpacing.xxs.h,
              children: [
                if (offer.discountPercent > 0)
                  _DetailChip(
                    label: '${offer.discountPercent.toStringAsFixed(0)}% off',
                    icon: Icons.local_offer_outlined,
                    accent: true,
                  ),
                _DetailChip(
                  label: dealTypeLabel,
                  icon: Icons.storefront_outlined,
                ),
                if (offer.isViewOnlyOffer)
                  _DetailChip(
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
              SizedBox(height: AppSpacing.xs.h),
              Text(
                externalUrl,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: tt.bodySmall?.copyWith(color: muted),
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
    final backgroundColor = accent
        ? _OfferDetailSheet._discountAccent.withValues(alpha: 0.12)
        : cs.surfaceContainerHigh;
    final foregroundColor =
        accent ? const Color(0xFF9A5200) : cs.onSurfaceVariant;

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
            color: accent ? _OfferDetailSheet._discountAccent : cs.onSurfaceVariant,
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
