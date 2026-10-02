part of 'package:aajhee/src/features/settings/presentation/settings.dart';

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final tt = context.theme.textTheme;
    final cs = context.theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h, left: AppSpacing.xs.w),
      child: Text(
        label,
        style: tt.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: cs.onSurfaceVariant,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
