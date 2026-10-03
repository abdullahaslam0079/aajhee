part of 'package:aajhee/src/features/commerce/presentation/screens/store_catalog_screen.dart';

class _StoreHighlights extends StatelessWidget {
  const _StoreHighlights({
    required this.supportsSameDay,
    required this.supportsNationwide,
    required this.hasWhatsApp,
    required this.showOnline,
    required this.showInStore,
  });

  final bool supportsSameDay;
  final bool supportsNationwide;
  final bool hasWhatsApp;
  final bool showOnline;
  final bool showInStore;

  @override
  Widget build(BuildContext context) {
    final items = <_HighlightItem>[
      if (supportsSameDay)
        const _HighlightItem(
          icon: Icons.bolt_rounded,
          label: 'Same-day',
        )
      else if (supportsNationwide)
        const _HighlightItem(
          icon: Icons.public_rounded,
          label: 'Nationwide',
        ),
      if (showOnline || showInStore)
        _HighlightItem(
          icon: Icons.storefront_outlined,
          label: [
            if (showOnline) 'Online',
            if (showInStore) 'In-store',
          ].join(' · '),
        ),
      if (hasWhatsApp)
        const _HighlightItem(
          icon: Icons.chat_rounded,
          label: 'WhatsApp',
        ),
    ];

    if (items.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: items.map((item) => _HighlightChip(item: item)).toList(),
    );
  }
}

class _HighlightItem {
  const _HighlightItem({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;
}

class _HighlightChip extends StatelessWidget {
  const _HighlightChip({required this.item});

  final _HighlightItem item;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: AppBorders.full,
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.75),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.icon, size: 14, color: cs.primary),
          SizedBox(width: 5.w),
          Text(
            item.label,
            style: tt.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
