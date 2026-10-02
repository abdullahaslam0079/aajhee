part of 'package:aajhee/src/features/settings/presentation/settings.dart';

class _ProfileMetaRow extends StatelessWidget {
  const _ProfileMetaRow({
    required this.icon,
    required this.label,
    required this.muted,
    required this.textStyle,
  });

  final IconData icon;
  final String label;
  final Color muted;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: muted),
        SizedBox(width: AppSpacing.sm.w),
        Expanded(
          child: Text(
            label,
            style: textStyle?.copyWith(
              color: muted,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
