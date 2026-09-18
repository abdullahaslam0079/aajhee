import 'package:aajhee/src/features/home/data/models/offer_model.dart';
import 'package:aajhee/src/imports/core_imports.dart';
import 'package:aajhee/src/imports/packages_imports.dart';

/// Gradient banner used on the Top picks screen.
class TopPicksHighlightBanner extends StatelessWidget {
  const TopPicksHighlightBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final textTheme = context.theme.textTheme;
    final appColors = context.appColors;
    final onBanner = colorScheme.onPrimary;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.ms.w,
        vertical: AppSpacing.sm.h,
      ),
      decoration: BoxDecoration(
        borderRadius: AppBorders.lg,
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.88),
            appColors.deal.withValues(alpha: 0.85),
          ],
        ),
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: onBanner.withValues(alpha: 0.2),
              borderRadius: AppBorders.iconButton,
            ),
            child: Icon(
              Icons.local_fire_department_rounded,
              color: onBanner,
              size: 22,
            ),
          ),
          SizedBox(width: AppSpacing.sm.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Top picks for you',
                  style: textTheme.titleSmall?.copyWith(
                    color: onBanner,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Best deals nearby and online',
                  style: textTheme.labelSmall?.copyWith(
                    color: onBanner.withValues(alpha: 0.88),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Hot section title on Home with a View all action.
class TopPicksSectionHeader extends StatelessWidget {
  const TopPicksSectionHeader({
    super.key,
    required this.onViewAll,
  });

  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final appColors = context.appColors;

    return Row(
      children: [
        Icon(
          Icons.local_fire_department_rounded,
          size: 22,
          color: appColors.deal,
        ),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            'Top picks for you',
            style: tt.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
        ),
        TextButton(
          onPressed: onViewAll,
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            foregroundColor: cs.primary,
          ),
          child: Text(
            'View all',
            style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class OffersSearchBar extends StatelessWidget {
  const OffersSearchBar({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final textTheme = context.theme.textTheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorders.input,
        child: Ink(
          decoration: BoxDecoration(
            color: isDark
                ? colorScheme.surfaceContainerHigh
                : colorScheme.surfaceContainerLowest,
            borderRadius: AppBorders.input,
            border: Border.all(
              color: isDark
                  ? colorScheme.outline.withValues(alpha: 0.32)
                  : colorScheme.outlineVariant,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'Search brands or items',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
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

class OfferChannelFilterChips extends StatelessWidget {
  const OfferChannelFilterChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final OfferChannelFilter selected;
  final ValueChanged<OfferChannelFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: OfferChannelFilter.values.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final filter = OfferChannelFilter.values[index];
          final isSelected = filter == selected;
          final cs = context.theme.colorScheme;
          final tt = context.theme.textTheme;
          final isDark = cs.brightness == Brightness.dark;
          final bg = isSelected
              ? cs.primary
              : isDark
                  ? cs.surfaceContainerHigh
                  : cs.surfaceContainerLowest;
          final fg = isSelected ? cs.onPrimary : cs.onSurfaceVariant;
          final icon = switch (filter) {
            OfferChannelFilter.all => Icons.apps_rounded,
            OfferChannelFilter.online => Icons.language_rounded,
            OfferChannelFilter.inStore => Icons.storefront_outlined,
          };

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onSelected(filter),
              borderRadius: AppBorders.md,
              child: Ink(
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: AppBorders.md,
                  border: isSelected
                      ? null
                      : Border.all(
                          color: isDark
                              ? cs.outline.withValues(alpha: 0.32)
                              : cs.outlineVariant,
                        ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 14.sp, color: fg),
                      SizedBox(width: 5.w),
                      Text(
                        filter.label,
                        style: tt.labelMedium?.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: fg,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
