part of 'package:aajhee/src/features/commerce/presentation/screens/checkout_screen.dart';

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      color: cs.surfaceContainerLowest,
      borderRadius: AppBorders.card,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: AppBorders.card,
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Padding(
          padding: EdgeInsets.all(14.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
              SizedBox(height: 12.h),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
