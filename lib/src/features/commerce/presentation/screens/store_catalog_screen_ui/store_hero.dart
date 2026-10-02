part of 'package:aajhee/src/features/commerce/presentation/screens/store_catalog_screen.dart';

class _StoreHero extends StatelessWidget {
  const _StoreHero({
    required this.businessName,
    required this.branchName,
    required this.logoUrl,
    required this.showOnline,
    required this.showInStore,
    required this.address,
    required this.canNavigate,
    required this.contacts,
    required this.onContact,
    required this.isVerified,
    required this.supportsSameDay,
    required this.supportsNationwide,
    required this.whatsAppColor,
    this.ratingAvg,
    this.ratingCount = 0,
    this.deliveryFeeLabel,
    this.openingHours,
    this.whatsappContact,
    this.onNavigate,
  });

  final String businessName;
  final String branchName;
  final String? logoUrl;
  final String? ratingAvg;
  final int ratingCount;
  final bool isVerified;
  final bool supportsSameDay;
  final bool supportsNationwide;
  final String? deliveryFeeLabel;
  final String? openingHours;
  final bool showOnline;
  final bool showInStore;
  final String address;
  final bool canNavigate;
  final Map<String, dynamic>? whatsappContact;
  final List<Map<String, dynamic>> contacts;
  final ValueChanged<Map<String, dynamic>> onContact;
  final VoidCallback? onNavigate;
  final Color whatsAppColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final hasDeliveryBadges = supportsSameDay ||
        supportsNationwide ||
        (deliveryFeeLabel != null && deliveryFeeLabel!.isNotEmpty);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: AppBorders.card,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 8.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppBorders.card.topLeft.x),
              ),
              gradient: LinearGradient(
                colors: [
                  cs.primary,
                  cs.primary.withValues(alpha: 0.65),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    StoreLogoBadge(
                      name: businessName,
                      imageUrl: logoUrl,
                      size: 72,
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  businessName,
                                  style: tt.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: cs.onSurface,
                                    letterSpacing: -0.4,
                                    height: 1.15,
                                  ),
                                ),
                              ),
                              if (isVerified) ...[
                                SizedBox(width: 6.w),
                                const _VerifiedBadge(),
                              ],
                            ],
                          ),
                          if (branchName.isNotEmpty) ...[
                            SizedBox(height: 4.h),
                            Text(
                              branchName,
                              style: tt.bodyMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          if (ratingCount > 0) ...[
                            SizedBox(height: 6.h),
                            Text(
                              '★ ${ratingAvg ?? '0.00'} ($ratingCount)',
                              style: tt.labelLarge?.copyWith(
                                color: const Color(0xFFE6A817),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                          if (hasDeliveryBadges) ...[
                            SizedBox(height: 10.h),
                            Wrap(
                              spacing: 8.w,
                              runSpacing: 6.h,
                              children: [
                                if (supportsSameDay)
                                  const _DeliveryChip(
                                    label: 'Same-day',
                                    icon: Icons.bolt_rounded,
                                    emphasized: true,
                                  ),
                                if (supportsNationwide)
                                  const _DeliveryChip(
                                    label: 'Nationwide',
                                    icon: Icons.public_rounded,
                                  ),
                                if (deliveryFeeLabel != null)
                                  _DeliveryChip(
                                    label: deliveryFeeLabel!,
                                    icon: Icons.local_shipping_outlined,
                                  ),
                              ],
                            ),
                          ],
                          if (!hasDeliveryBadges &&
                              (showOnline || showInStore)) ...[
                            SizedBox(height: 10.h),
                            Text(
                              [
                                if (showOnline) 'Online',
                                if (showInStore) 'In-store',
                              ].join(' · '),
                              style: tt.labelSmall?.copyWith(
                                color: cs.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                if (openingHours != null && openingHours!.isNotEmpty) ...[
                  SizedBox(height: 14.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 18,
                        color: cs.onSurfaceVariant,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          openingHours!,
                          style: tt.bodyMedium?.copyWith(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (showInStore && address.isNotEmpty) ...[
                  SizedBox(height: 14.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHigh.withValues(alpha: 0.55),
                      borderRadius: AppBorders.md,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 20,
                          color: cs.primary,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            address,
                            style: tt.bodyMedium?.copyWith(
                              color: cs.onSurface,
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (whatsappContact != null) ...[
                  SizedBox(height: 12.h),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => onContact(whatsappContact!),
                      style: FilledButton.styleFrom(
                        backgroundColor: whatsAppColor,
                        foregroundColor: Colors.white,
                        minimumSize: Size.fromHeight(46.h),
                      ),
                      icon: const Icon(Icons.chat_rounded),
                      label: const Text('WhatsApp'),
                    ),
                  ),
                ],
                if (canNavigate && onNavigate != null) ...[
                  SizedBox(height: 10.h),
                  SizedBox(
                    width: double.infinity,
                    child: whatsappContact != null
                        ? OutlinedButton.icon(
                            onPressed: onNavigate,
                            icon: const Icon(Icons.directions_rounded),
                            label: const Text('Navigate to store'),
                          )
                        : FilledButton.icon(
                            onPressed: onNavigate,
                            icon: const Icon(Icons.directions_rounded),
                            label: const Text('Navigate to store'),
                          ),
                  ),
                ],
                if (contacts.isNotEmpty) ...[
                  SizedBox(height: 16.h),
                  Text(
                    'Contact',
                    style: tt.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: contacts
                        .map(
                          (contact) => _ContactButton(
                            contact: contact,
                            onPressed: () => onContact(contact),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
