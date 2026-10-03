part of 'package:aajhee/src/features/commerce/presentation/screens/store_catalog_screen.dart';

class _StoreAboutPanel extends StatelessWidget {
  const _StoreAboutPanel({
    required this.branchName,
    required this.showOnline,
    required this.showInStore,
    required this.address,
    required this.canNavigate,
    required this.contacts,
    required this.onContact,
    required this.whatsAppColor,
    this.openingHours,
    this.whatsappContact,
    this.onNavigate,
  });

  final String branchName;
  final String? openingHours;
  final bool showOnline;
  final bool showInStore;
  final String address;
  final bool canNavigate;
  final Map<String, dynamic>? whatsappContact;
  final List<Map<String, dynamic>> contacts;
  final ValueChanged<Map<String, dynamic>> onContact;
  final VoidCallback? onNavigate;
  final Color whatsAppColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: AppBorders.card,
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.75),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Store details',
            style: tt.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
          ),
          if (branchName.isNotEmpty) ...[
            SizedBox(height: 12.h),
            _AboutRow(
              icon: Icons.storefront_outlined,
              label: 'Branch',
              value: branchName,
            ),
          ],
          if (openingHours != null && openingHours!.isNotEmpty) ...[
            SizedBox(height: 12.h),
            _AboutRow(
              icon: Icons.schedule_rounded,
              label: 'Hours',
              value: openingHours!,
            ),
          ],
          if (showOnline || showInStore) ...[
            SizedBox(height: 12.h),
            _AboutRow(
              icon: Icons.shopping_bag_outlined,
              label: 'Availability',
              value: [
                if (showOnline) 'Online shopping',
                if (showInStore) 'In-store pickup / visit',
              ].join('\n'),
            ),
          ],
          if (showInStore && address.isNotEmpty) ...[
            SizedBox(height: 14.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh.withValues(alpha: 0.55),
                borderRadius: AppBorders.md,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    size: 20,
                    color: cs.primary,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      address,
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (whatsappContact != null) ...[
            SizedBox(height: 14.h),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => onContact(whatsappContact!),
                style: FilledButton.styleFrom(
                  backgroundColor: whatsAppColor,
                  foregroundColor: Colors.white,
                  minimumSize: Size.fromHeight(46.h),
                ),
                icon: const Icon(Icons.chat_rounded),
                label: const Text('WhatsApp'),
              ),
            ),
          ],
          if (canNavigate && onNavigate != null) ...[
            SizedBox(height: 10.h),
            SizedBox(
              width: double.infinity,
              child: whatsappContact != null
                  ? OutlinedButton.icon(
                      onPressed: onNavigate,
                      icon: const Icon(Icons.directions_rounded),
                      label: const Text('Navigate to store'),
                    )
                  : FilledButton.icon(
                      onPressed: onNavigate,
                      icon: const Icon(Icons.directions_rounded),
                      label: const Text('Navigate to store'),
                    ),
            ),
          ],
          if (contacts.isNotEmpty) ...[
            SizedBox(height: 18.h),
            Text(
              'Contact',
              style: tt.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
              ),
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: contacts
                  .map(
                    (contact) => _ContactButton(
                      contact: contact,
                      onPressed: () => onContact(contact),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  const _AboutRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: cs.onSurfaceVariant),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: tt.labelMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
