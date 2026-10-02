part of 'package:aajhee/src/features/commerce/presentation/screens/product_detail_screen.dart';

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final Map<String, dynamic> review;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final rating = int.tryParse('${review['rating'] ?? 0}') ?? 0;
    final comment = review['comment']?.toString().trim() ?? '';
    final name = review['user_display_name']?.toString() ?? 'Customer';
    final reply = review['merchant_reply']?.toString().trim() ?? '';
    final images = ((review['images'] as List?) ?? const [])
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: AppBorders.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ...List.generate(
                5,
                (i) => Icon(
                  i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 14.sp,
                  color: const Color(0xFFE6A817),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  name,
                  style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: AppBorders.full,
                ),
                child: Text(
                  'Verified',
                  style: tt.labelSmall?.copyWith(
                    color: cs.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (comment.isNotEmpty) ...[
            SizedBox(height: 6.h),
            Text(comment, style: tt.bodyMedium),
          ],
          if (images.isNotEmpty) ...[
            SizedBox(height: 8.h),
            SizedBox(
              height: 64.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
                itemBuilder: (_, i) {
                  final url = images[i]['image_url']?.toString() ?? '';
                  if (url.isEmpty) return const SizedBox.shrink();
                  return ClipRRect(
                    borderRadius: AppBorders.sm,
                    child: Image.network(
                      url,
                      width: 64.w,
                      height: 64.h,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
          ],
          if (reply.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: AppBorders.sm,
              ),
              child: Text(
                'Store reply: $reply',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
