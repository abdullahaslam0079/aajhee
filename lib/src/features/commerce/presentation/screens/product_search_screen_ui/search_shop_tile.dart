part of 'package:aajhee/src/features/commerce/presentation/screens/product_search_screen.dart';

class _SearchShopTile extends StatelessWidget {
  const _SearchShopTile({
    required this.branch,
    required this.onTap,
  });

  final MapBranchModel branch;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final category = branch.categoryName.trim();

    return Material(
      color: cs.surfaceContainerLowest,
      borderRadius: AppBorders.card,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorders.card,
        child: Padding(
          padding: EdgeInsets.all(10.r),
          child: Row(
            children: [
              StoreLogoBadge(
                name: branch.displayName,
                imageUrl: branch.logoUrl,
                size: 64,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      branch.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (category.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Text(
                        category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
