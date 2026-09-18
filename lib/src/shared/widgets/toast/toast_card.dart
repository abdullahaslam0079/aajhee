import '../../../imports/imports.dart';

/// ToastCard widget to display decent and rich looking toast.
class ToastCard extends StatelessWidget {
  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final Color? color;
  final Color? shadowColor;
  final void Function()? onTap;

  const ToastCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.color,
    this.shadowColor,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: color ?? cs.surfaceContainerLowest,
        borderRadius: AppBorders.lg,
        border: Border.all(color: cs.outlineVariant),
        boxShadow: AppShadows.elevated,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: leading,
        ),
        trailing: trailing,
        subtitle: subtitle,
        title: title,
        onTap: onTap,
      ),
    );
  }
}
