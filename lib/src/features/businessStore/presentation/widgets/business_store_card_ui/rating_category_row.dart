part of 'package:aajhee/src/features/businessStore/presentation/widgets/business_store_card.dart';

class _RatingCategoryRow extends StatelessWidget {
  const _RatingCategoryRow({
    required this.showRating,
    required this.ratingAvg,
    required this.ratingCount,
    required this.category,
    required this.muted,
    required this.textTheme,
  });

  final bool showRating;
  final double? ratingAvg;
  final int? ratingCount;
  final String category;
  final Color muted;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    if (!showRating && category.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        if (showRating) ...[
          const Icon(
            Icons.star_rounded,
            size: 14,
            color: Color(0xFFF5B400),
          ),
          SizedBox(width: 3.w),
          Text(
            ratingAvg!.toStringAsFixed(1),
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.1,
              color: muted,
            ),
          ),
          if (ratingCount != null && ratingCount! > 0)
            Text(
              ' ($ratingCount)',
              style: textTheme.labelSmall?.copyWith(
                color: muted,
                fontWeight: FontWeight.w500,
                height: 1.1,
              ),
            ),
          if (category.isNotEmpty) ...[
            Text(
              '  ·  ',
              style: textTheme.labelSmall?.copyWith(
                color: muted.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
        if (category.isNotEmpty)
          Flexible(
            child: Text(
              category,
              style: textTheme.labelSmall?.copyWith(
                color: muted,
                fontWeight: FontWeight.w500,
                height: 1.1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}
