part of 'package:aajhee/src/features/commerce/presentation/screens/product_detail_screen.dart';

class _SoldByRow extends StatelessWidget {
  const _SoldByRow({
    required this.businessName,
    required this.logoUrl,
    required this.onTap,
    this.isVerified = false,
  });

  final String businessName;
  final String? logoUrl;
  final VoidCallback onTap;
  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      color: cs.surfaceContainerLowest,
      borderRadius: AppBorders.md,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorders.md,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: AppBorders.md,
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            child: Row(
              children: [
                StoreLogoBadge(
                  name: businessName,
                  imageUrl: logoUrl,
                  size: 40,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sold by',
                        style: tt.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              businessName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: tt.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: cs.onSurface,
                              ),
                            ),
                          ),
                          if (isVerified) ...[
                            SizedBox(width: 6.w),
                            const _VerifiedChip(),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  'Visit store',
                  style: tt.labelMedium?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 2.w),
                Icon(Icons.chevron_right_rounded, color: cs.primary, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
