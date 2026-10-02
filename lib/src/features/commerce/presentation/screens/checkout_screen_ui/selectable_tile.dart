part of 'package:aajhee/src/features/commerce/presentation/screens/checkout_screen.dart';

class _SelectableTile extends StatelessWidget {
  const _SelectableTile({
    required this.selected,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final bool selected;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Material(
        color: selected
            ? cs.primary.withValues(alpha: 0.08)
            : cs.surfaceContainerHigh.withValues(alpha: 0.55),
        borderRadius: AppBorders.md,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppBorders.md,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            decoration: BoxDecoration(
              borderRadius: AppBorders.md,
              border: Border.all(
                color: selected ? cs.primary : cs.outlineVariant,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: selected ? cs.primary : cs.onSurfaceVariant,
                  size: 20,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                      if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                        SizedBox(height: 2.h),
                        Text(
                          subtitle!,
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ],
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
