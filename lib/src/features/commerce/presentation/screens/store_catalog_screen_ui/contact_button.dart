part of 'package:aajhee/src/features/commerce/presentation/screens/store_catalog_screen.dart';

class _ContactButton extends StatelessWidget {
  const _ContactButton({
    required this.contact,
    required this.onPressed,
  });

  final Map<String, dynamic> contact;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final type =
        (contact['contact_type']?.toString() ?? 'contact').trim().toLowerCase();
    final rawValue = contact['value']?.toString().trim() ?? '';
    final displayValue = type == 'phone'
        ? formatPakistaniMobileInternational(rawValue)
        : rawValue;
    final (icon, label) = switch (type) {
      'phone' => (Icons.phone_rounded, 'Call'),
      'email' => (Icons.mail_outline_rounded, 'Email'),
      'whatsapp' => (Icons.chat_rounded, 'WhatsApp'),
      _ => (Icons.contact_page_outlined, type.isEmpty ? 'Contact' : type),
    };

    return Material(
      color: cs.primary.withValues(alpha: 0.08),
      borderRadius: AppBorders.md,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppBorders.md,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            borderRadius: AppBorders.md,
            border: Border.all(color: cs.primary.withValues(alpha: 0.22)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: cs.primary),
              SizedBox(width: 8.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: tt.labelLarge?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (displayValue.isNotEmpty)
                    Text(
                      displayValue,
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
