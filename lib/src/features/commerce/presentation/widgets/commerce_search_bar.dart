import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';

/// Tappable search field used on commerce and shops screens.
/// Magnifying glass only — no camera / image-search affordance.
class CommerceSearchBar extends StatelessWidget {
  const CommerceSearchBar({
    super.key,
    required this.onTap,
    this.hintText = 'Search for products, brands and more...',
  });

  final VoidCallback onTap;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final textTheme = context.theme.textTheme;
    final outline = colorScheme.outline.withValues(alpha: 0.55);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorders.input,
        child: Ink(
          decoration: BoxDecoration(
            color: AppBrandColors.surface,
            borderRadius: AppBorders.input,
            border: Border.all(color: outline),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    hintText,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
