part of 'package:aajhee/src/features/businessStore/presentation/widgets/business_store_card.dart';

class _ViewAllProductsButton extends StatelessWidget {
  const _ViewAllProductsButton({
    required this.label,
    this.onTap,
  });

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    return Material(
      color: AppBrandColors.primaryContainer,
      borderRadius: AppBorders.full,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorders.full,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          child: Row(
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: 16,
                color: cs.primary,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  label,
                  style: tt.labelMedium?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                size: 14,
                color: cs.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
