part of 'package:aajhee/src/features/commerce/presentation/screens/store_catalog_screen.dart';

/// Foodpanda-style section title with a circular "see all" chevron.
class _StoreSectionHeader extends StatelessWidget {
  const _StoreSectionHeader({
    required this.title,
    required this.onSeeAll,
  });

  final String title;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 12.w, 10.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: tt.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                color: cs.onSurface,
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onSeeAll,
              customBorder: const CircleBorder(),
              child: Ink(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.9),
                  ),
                  color: cs.surfaceContainerLowest,
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: cs.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
